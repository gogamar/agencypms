class VrentalsController < ApplicationController
  before_action :set_vrental, only: [:show, :edit, :update, :destroy, :copy_rates, :send_rates, :delete_rates, :delete_year_rates, :get_rates, :export_beds, :update_beds, :get_bookings, :annual_statement, :fetch_earnings, :upload_dates]

  def index
    all_vrentals = policy_scope(Vrental).order(created_at: :desc)
    @pagy, @vrentals = pagy(all_vrentals, page: params[:page], items: 10)
  end

  def list
    @vrentals = policy_scope(Vrental).includes(:vrowner)
    @vrentals = @vrentals.where('unaccent(name) ILIKE ?', "%#{params[:name]}%") if params[:name].present?
    @vrentals = @vrentals.where(status: params[:status]) if params[:status].present?
    @vrentals = @vrentals.order("#{params[:column]} #{params[:direction]}")
    @pagy, @vrentals = pagy(@vrentals, page: params[:page], items: 10)
    render(partial: 'vrentals', locals: { vrentals: @vrentals })
  end

  def total_earnings
    @vrentals = policy_scope(Vrental)
    @pagy, @vrentals = pagy(@vrentals, page: params[:page], items: 10)
    authorize @vrentals
    @average_commission = Vrental.where.not(commission: nil).average(:commission)
    @total_rate_price_all_vrentals = Vrental.calculate_total_rate_price_for_all
    @total_bookings_all_vrentals = Booking.where.not(price: nil).sum(:price)
    @total_earnings_all_vrentals = Earning.where.not(amount: nil).sum(:amount)
    @total_agency_fees = Vrental.total_agency_fees
  end

  def list_earnings
    @vrentals = policy_scope(Vrental)
    authorize @vrentals
    @vrentals = @vrentals.where.not(commission: nil)

    if params[:name].present?
      @vrentals = @vrentals.where('unaccent(name) ILIKE ?', "%#{params[:name]}%")
    end

    order_direction = params[:direction].upcase if params[:direction]

    case params[:column]
    when 'vrental_name'
      @vrentals = @vrentals.order(name: order_direction)
    when 'total_earnings'
      @vrentals = @vrentals
                   .joins(:earnings)
                   .group('vrentals.id')
                   .order("SUM(earnings.amount) #{order_direction}")
    when 'agency_fees'
      @vrentals = @vrentals
      .select('vrentals.*,
               (SELECT SUM(earnings.amount) FROM earnings WHERE earnings.vrental_id = vrentals.id AND earnings.amount IS NOT NULL) * vrentals.commission AS agency_fees')
      .order("agency_fees #{order_direction} NULLS LAST")
    else
      # Handle default sorting here if needed
    end

    @pagy, @vrentals = pagy(@vrentals, page: params[:page], items: 10)
    render(partial: 'vrentals_earnings', locals: { vrentals: @vrentals })
  end

  def annual_statement
    @vrowner = @vrental.vrowner
    @year = params[:year].to_i
    @statements = policy_scope(Statement)
    @annual_statements = @vrental.statements.where("EXTRACT(year FROM start_date) = ?", params[:year])
    authorize @annual_statements
    @annual_earnings = @vrental.earnings
                      .where(statement_id: @annual_statements.ids)
                      .where.not(amount: 0)
                      .order(:date)
    @annual_expenses = @vrental.expenses.where(statement_id: @annual_statements.ids)
    @annual_expenses_owner = @vrental.expenses.where(statement_id: @annual_statements.ids).where(expense_type: 'owner')
    @annual_expenses_agency = @vrental.expenses.where(statement_id: @annual_statements.ids).where(expense_type: 'agency')
    @total_annual_expenses_owner = @annual_expenses_owner.sum(:amount)
    @total_annual_earnings = @annual_earnings.sum(:amount)
    @annual_vrowner_payments = VrownerPayment.where(statement_id: @annual_statements.ids).order(:date)
    @annual_vrowner_payments_total = @annual_vrowner_payments.sum(:amount)
    @annual_agency_commission = (@annual_earnings.sum(:amount) * @vrental.commission).round(2)
    @annual_agency_commission_vat = @annual_agency_commission * 0.21
    @annual_net_income_owner = @annual_earnings.sum(:amount) - @annual_expenses_owner.sum(:amount) - @annual_agency_commission - @annual_agency_commission_vat

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@vrental.name}, liquidació #{Date.new(@year, 1, 1)} - #{Date.new(@year, 12, 31)}",
        template: "vrentals/annual_statement",
        margin:  {
          top: 70,
          bottom: 25,
          left: 10,
          right: 10},
        header: {
          font_size: 9,
          spacing: 30,
          content: render_to_string(
            'shared/pdf_header'
          )
         },
         formats: [:html],
         disposition: :inline,
         page_size: 'A4',
         page_breaks: true,
         dpi: '75',
         zoom: 1,
         layout: 'pdf',
         footer: {
          font_size: 9,
          spacing: 5,
          right: "#{t("page")} [page] #{t("of")} [topage]",
          left: @year.present? ? l(Date.new(@year, 12, 31), format: :long) : ''
        }
      end
    end
  end

  def show
    authorize @vrental
    @vrentals = policy_scope(Vrental).order(name: :asc)
    @features = policy_scope(Feature)
    @features = Feature.all
  end

  def copy
    @source = Vrental.find(params[:id])
    @vrental = @source.dup
    @vrental.name = "#{@vrental.name} CÒPIA"
    @vrental.beds_prop_id = nil
    @vrental.beds_room_id = nil
    @vrental.prop_key = nil
    @vrental.rates = []
    @source.rates.each { |rate| @vrental.rates << rate.dup }
    @vrental.features = []
    # instead of duplicating features, the same features need to be assigned to the new record
    @source.features.each { |feature| @vrental.features << feature }
    authorize @vrental
    @vrental.save!
    redirect_to @vrental, notice: "S'ha creat una còpia de l'immoble: #{@vrental.name}."
  end

  def copy_rates
    current_year = params[:year]
    @vrental.copy_rates_to_next_year(current_year)
    authorize @vrental
    redirect_to vrental_rates_path(@vrental), notice: "Les tarifes ja estàn copiades."
  end

  def delete_rates
    @vrental.delete_this_year_rates_on_beds
    authorize @vrental
    redirect_to vrental_rates_path(@vrental), notice: "Les tarifes ja estàn esborrades. Ara les pots tornar a enviar"
  end

  def delete_year_rates
    @vrental.delete_year_rates(params[:year])
    redirect_to vrental_rates_path(@vrental), notice: "Les tarifes de #{params[:year]} ja estàn esborrades."
  end

  def upload_dates
    rate_plan = RatePlan.find(params[:rate_plan_id])
    @vrental.upload_dates_to_rates(rate_plan)
    redirect_to vrental_rates_path(@vrental), notice: "Les dates ja estàn importades."
  end

  def send_rates
    @vrental.send_rates_to_beds
    authorize @vrental
    redirect_to vrental_rates_path(@vrental), notice: "Les tarifes ja estàn enviades."
  end

  def get_rates
    @vrental.get_rates_from_beds
    authorize @vrental
    redirect_back(fallback_location: vrental_rates_path(@vrental) + "#tarifes", notice: "Ja s'han importat les tarifes.")
  end

  def get_bookings
    @vrental.get_bookings_from_beds
    authorize @vrental
    if params[:request_context] == 'statements'
      redirect_to vrental_statements_path(@vrental), notice: "S'han importat les reserves."
    else
    redirect_to vrental_earnings_path(@vrental), notice: "S'han importat les reserves."
    end
    # redirect_to vrental_earnings_path(@vrental), notice: (result == "property with this propKey not found in account" ? "Immoble amb aquesta clau secreta no existeix a Beds24." : "Ja s'han importat les reserves.")
  end

  def import_properties
    policy_scope(Vrental)
    Vrental.import_properties_from_beds
    redirect_to vrentals_path, notice: "Properties imported"
  end

  def export_beds
    @vrental.create_property_on_beds
    authorize @vrental
    redirect_to @vrental, notice: "L'immoble ja està a Beds."
  end

  def update_beds
    @vrental.update_on_beds
    authorize @vrental
    redirect_to @vrental, notice: "L'immoble s'ha actualitzat creat a Beds."
  end

  def new
    @vrental = Vrental.new
    authorize @vrental
  end

  def create
    @vrental = Vrental.new(vrental_params)
    @vrental.user_id = current_user.id
    authorize @vrental

    if @vrental.save
      redirect_to add_features_vrental_path(@vrental)
    else
      render :new
    end
  end

  def add_features
    @vrental = Vrental.find(params[:id])
    authorize @vrental
  end

  def add_vrowner
    @vrental = Vrental.find(params[:id])
    authorize @vrental
    @vrowner = Vrowner.new
  end

  def fetch_earnings
    authorize @vrental
    start_date_param = params[:start_date]
    end_date_param = params[:end_date]

    if start_date_param && end_date_param
      start_date = Date.parse(start_date_param)
      end_date = Date.parse(end_date_param)

      earnings = @vrental.earnings.where(date: start_date..end_date).order(:date)
      render earnings, layout: false
    else
      # Handle the case where start_date or end_date is missing or not in the correct format
      # You might want to render an error message or redirect to an error page.
    end
  end

  def edit
    @feature_list = Feature.all.uniq
    authorize @vrental
    @vrowner = @vrental.vrowner
    # @vrowners = policy_scope(Vrowner).sort_by(&:fullname)
  end

  def update
    authorize @vrental
    @vrowner = @vrental.vrowner
    request_context = params[:vrental][:request_context]
    if @vrental.update(vrental_params)
      respond_to do |format|
        format.html {
          if request_context && request_context == 'add_features'
            redirect_to add_vrowner_vrental_path(@vrental)
          else
            redirect_to vrentals_path, notice: 'S\'ha modificat l\'immoble.'
          end
        }
        format.json { render json: @vrental, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vrental.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @vrental
    @vrental.destroy
    redirect_to vrentals_url, notice: 'S\'ha esborrat l\'immoble.'
  end

  private

  def set_vrental
    @vrental = Vrental.find(params[:id])
    authorize @vrental
  end

  def vrental_params
    params.require(:vrental).permit(
      :name, :address, :licence, :cadastre, :habitability, :commission,
      :beds_prop_id, :beds_room_id, :prop_key, :vrowner_id, :max_guests,
      :description, :description_es, :description_fr, :description_en, :status, :office_id, :rate_plan_id, feature_ids: []
    )
  end
end
