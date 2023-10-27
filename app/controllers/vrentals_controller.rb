class VrentalsController < ApplicationController
  before_action :set_vrental, only: [:show, :edit, :update, :destroy, :copy_rates, :send_rates, :delete_rates, :delete_year_rates, :get_rates, :update_on_beds, :update_from_beds, :update_owner_from_beds, :get_bookings, :annual_statement, :fetch_earnings, :upload_dates, :edit_photos, :send_photos, :import_photos, :import_from_group]

  def index
    @vrentals = policy_scope(Vrental).order(created_at: :desc)
    @statuses = @vrentals.pluck(:status).uniq
    @towns = Town.all
    @vrentals = @vrentals.where('unaccent(name) ILIKE ?', "%#{params[:filter_name]}%") if params[:filter_name].present?
    @vrentals = @vrentals.where(status: params[:filter_status]) if params[:filter_status].present?
    @vrentals = @vrentals.where(town_id: params[:filter_town]) if params[:filter_town].present?
    @pagy, @vrentals = pagy(@vrentals, page: params[:page], items: 10)
  end

  def list
    @vrentals = policy_scope(Vrental)
    @statuses = @vrentals.pluck(:status).uniq
    @towns = Town.all
    @vrentals = @vrentals.includes(:owner)
    @vrentals = @vrentals.where('unaccent(name) ILIKE ?', "%#{params[:filter_name]}%") if params[:filter_name].present?
    @vrentals = @vrentals.where(status: params[:filter_status]) if params[:filter_status].present?
    @vrentals = @vrentals.where(town_id: params[:filter_town]) if params[:filter_town].present?
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

  def total_city_tax
    @vrentals = policy_scope(Vrental).order(name: :asc)
    @vrentals_with_bookings = @vrentals.select { |vrental| vrental.bookings.present? }
    authorize @vrentals
  end

  def download_city_tax
    vrentals = policy_scope(Vrental).order(name: :asc)
    vrentals_with_bookings = vrentals.select { |vrental| vrental.bookings.present? }
    authorize vrentals

    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: 'Taxa turistica') do |sheet|
      sheet.add_row ['Propietari', 'DNI', 'Propietat', 'NºHUT', 'Adreça immoble', 'Població', 'Base taxa tur.', 'IVA taxa tur.', 'Taxa amb IVA', 'Total estades']

      vrentals_with_bookings.each do |vrental|
        city_tax_hash = vrental.total_city_tax(Date.today.beginning_of_year, Date.today.end_of_year)
        bookings_number = vrental.bookings.where(checkin: Date.today.beginning_of_year..Date.today.end_of_year).count
        sheet.add_row [vrental.owner&.fullname, vrental.owner&.document, vrental.name, vrental.licence, vrental.address, vrental.town&.name, city_tax_hash[:base], city_tax_hash[:vat], city_tax_hash[:tax], bookings_number]
      end
    end

    @tmp_file = Tempfile.new('taxa_turistica_huts.xlsx')
    package.serialize(@tmp_file.path)

    send_file @tmp_file.path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: 'taxa_turistica_huts.xlsx'
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
    @owner = @vrental.owner
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
    @annual_owner_payments = OwnerPayment.where(statement_id: @annual_statements.ids).order(:date)
    @annual_owner_payments_total = @annual_owner_payments.sum(:amount)
    @annual_agency_commission = (@annual_earnings.sum(:amount) * (@vrental.commission || 0)).round(2)
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

  def edit_photos
    @vrgroup = @vrental.vrgroup
    @vrgroup_photos_ids = @vrgroup.photos.pluck(:id).compact if @vrgroup and @vrgroup.photos.present?
    # @vrgroup_photos = @vrental.image_urls.where(photo_id: @vrgroup_photos_ids)
    @image_urls = @vrental.image_urls.order(position: :asc)
    @all_group_photos_imported = @vrental.all_group_photos_imported?
  end

  def import_from_group
    @vrgroup = @vrental.vrgroup
    create_new_image_urls(@vrgroup.photos)
    redirect_to edit_photos_vrental_path(@vrental), notice: "Importació del grup acabada."
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
    from_date = params[:from_date] if params[:from_date].present?
    @vrental.get_bookings_from_beds(from_date)
    authorize @vrental
    if params[:request_context] == 'statements'
      redirect_to vrental_statements_path(@vrental), notice: "S'han importat les reserves."
    else
    redirect_to vrental_earnings_path(@vrental), notice: "S'han importat les reserves."
    end
    # redirect_to vrental_earnings_path(@vrental), notice: (result == "property with this propKey not found in account" ? "Immoble amb aquesta clau secreta no existeix a Beds24." : "Ja s'han importat les reserves.")
  end

  def update_on_beds
    @vrental.update_vrental_on_beds
    redirect_to @vrental, notice: "S'han exportat canvis a Beds."
  end

  def import_photos
    @vrental.import_photos_from_beds
    redirect_to @vrental, notice: "S'han importat les fotos des de Beds."
  end

  def send_photos
    @vrental.send_photos_to_beds
    redirect_to @vrental, notice: "S'han enviat les fotos a Beds."
  end

  def update_from_beds
    @vrental.update_vrental_from_beds
    redirect_to @vrental, notice: "S'han importat canvis des de Beds."
  end

  def update_owner_from_beds
    @vrental.update_owner_from_beds
    redirect_to @vrental, notice: "S'ha actualitzat el propietari des de Beds."
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

  def add_owner
    @vrental = Vrental.find(params[:id])
    authorize @vrental
    @owner = Owner.new
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
    @owner = @vrental.owner
    # @owners = policy_scope(Owner).sort_by(&:fullname)
  end

  def update
    authorize @vrental
    @owner = @vrental.owner
    request_context = params[:vrental][:request_context]

    if @vrental.update(vrental_params)
      handle_update_success(request_context)
    else
      handle_update_failure
    end
  end

  def destroy
    authorize @vrental
    @vrental.destroy
    redirect_to vrentals_url, notice: 'S\'ha esborrat l\'immoble.'
  end

  private

  def handle_update_success(request_context)
    respond_to do |format|
      format.html { redirect_after_update(request_context) }
      format.json { render json: @vrental, status: :ok }
    end
  end

  def handle_update_failure
    respond_to do |format|
      format.html { render_update_failure }
      format.json { render json: @vrental.errors, status: :unprocessable_entity }
    end
  end

  def redirect_after_update(request_context)
    if request_context == 'add_features'
      redirect_to add_owner_vrental_path(@vrental)
    elsif request_context == 'add_photos'
      create_new_image_urls(@vrental.photos)
      redirect_to edit_photos_vrental_path(@vrental)
    else
      redirect_to @vrental, notice: 'S\'ha modificat l\'immoble.'
    end
  end

  def create_new_image_urls(photos)
    existing_urls = @vrental.image_urls.pluck(:url).to_set

    photos.each_with_index do |photo, index|
      url = photo.url
      url_with_q_auto = url.gsub(/upload\//, 'upload/q_auto/')

      if !existing_urls.include?(url) && !existing_urls.include?(url_with_q_auto)
        @vrental.image_urls.create(url: url_with_q_auto, position: index + 1, photo_id: photo.id)
        existing_urls.add(url_with_q_auto)
      elsif existing_urls.include?(url)
        @vrental.image_urls.find_by(url: url).update(url: url_with_q_auto)
      end
    end
  end

  def render_update_failure
    error_messages = @vrental.errors.full_messages.join(", ")
    flash.now[:alert] = "No s'ha pogut modificar l'immoble. #{error_messages}"
    render :edit, status: :unprocessable_entity
  end

  def set_vrental
    @vrental = Vrental.find(params[:id])
    authorize @vrental
  end

  def vrental_params
    params.require(:vrental).permit(
      :name, :address, :licence, :cadastre, :habitability, :contract_type, :commission, :fixed_price_amount, :fixed_price_frequency, :beds_prop_id, :beds_room_id, :prop_key, :owner_id, :max_guests,
      :description_ca, :description_es, :description_fr, :description_en, :status, :office_id, :vrgroup_id, :rate_plan_id, :latitude, :longitude, :town_id, feature_ids: [], photos: []
    )
  end
end
