class VragreementsController < ApplicationController
  require 'date'
  before_action :set_vragreement, only: [:show, :edit, :update, :destroy ]
  before_action :set_vrental, only: [ :new, :create, :edit, :update ]

  def index
    @vrental = Vrental.find(params[:vrental_id]) if params[:vrental_id]
    active_vragreements = policy_scope(Vragreement).includes(:vrental).where.not('vrental.status' => "inactive")
    active_vragreements = active_vragreements.where(vrental_id: params[:immoble]) if params[:immoble].present?
    active_vragreements = active_vragreements.order(created_at: :desc)
    @pagy, @vragreements = pagy(active_vragreements, page: params[:page], items: 10)
  end

  def list
    @vragreements = policy_scope(Vragreement).includes(:vrental)
    # .where.not('vrental.status' => "inactive")
    @vragreements = @vragreements.where('vrental.status' => params[:status]) if params[:status].present?
    @vragreements = @vragreements.where(year: params[:year]) if params[:year].present?
    @vragreements = @vragreements.joins(:vrental).where('name ilike ?', "%#{params[:vrental]}%") if params[:vrental].present?
    @vragreements = @vragreements.order("#{params[:column]} #{params[:direction]}")
    @pagy, @vragreements = pagy(@vragreements, page: params[:page], items: 10)
    render(partial: 'vragreements', locals: { vragreements: @vragreements })
  end

  def show
    authorize @vragreement
    @vrentaltemplates = Vrentaltemplate.all
    @vragreements = Vragreement.all
    @vrowner = @vragreement.vrental.vrowner
    @vrental = @vragreement.vrental
    @vrates = Rate.where(vrental_id: @vrental).order(:firstnight)

    contract_rates = render_to_string(partial: 'rates')
    @vrcontrato = @vragreement.generate_contract_body(contract_rates)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: [@vrental.address, @vrowner].join('-'),
              template: "vragreements/show",
              margin:  {
              top: 50,
              bottom: 25,
              left: 10,
              right: 10},
              header: {
                font_size: 8,
                spacing: 20,
                content: render_to_string(
                  'shared/pdf_header'
                )
               },
              formats: [:html],
              disposition: :inline,
              page_size: 'A4',
              dpi: '75',
              zoom: 1,
              layout: 'pdf',
              footer: {
                font_size: 9,
                spacing: 5,
                right: "#{t("page")} [page] #{t("of")} [topage]",
                left: @vragreement.signdate.present? ? l(@vragreement.signdate, format: :long) : ''
              }
      end
    end
  end

  def new
    @vragreement = Vragreement.new
    authorize @vragreement
    @years_vragreement_exists = @vrental.vragreements.pluck(:year)
    next_three_years = [Date.today.year, Date.today.year + 1, Date.today.year + 2]
    merged_arrays = next_three_years + @years_vragreement_exists
    @years_vragreement_missing = merged_arrays.select { |year| merged_arrays.count(year) == 1 }
    @vrentaltemplates = policy_scope(Vrentaltemplate)
  end

  def edit
    authorize @vragreement
    @vrentaltemplates = policy_scope(Vrentaltemplate)
  end

  def create
    @vragreement = Vragreement.new(vragreement_params)
    @vragreement.vrental = @vrental
    authorize @vragreement
    if @vragreement.save
      redirect_to vragreements_path, notice: "Has creat el contracte per #{@vrental.name}."
    else
      render :new
    end
  end

  def update
    @vragreement.vrental = @vrental
    authorize @vragreement
    if @vragreement.update(vragreement_params)
      redirect_to @vragreement, notice: 'Has actualitzat el contracte.'
    else
      render :edit
    end
  end

  def destroy
    authorize @vragreement
    @vragreement.destroy
    redirect_to vragreements_path, notice: "Has esborrat el contracte del #{@vragreement.vrental.name}."
  end

  private

  def set_vragreement
    @vragreement = Vragreement.find(params[:id])
  end
  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
  end
  def set_vrowner
    @vrowner = Vrowner.find(params[:vrowner_id])
  end

  def set_vrentaltemplate
    @vrentaltemplate = @vragreement.vrentaltemplate
  end

  # Only allow a list of trusted parameters through.
  def vragreement_params
    params.require(:vragreement).permit(:status, :year, :signdate, :place, :start_date, :end_date, :vrental_id, :vrentaltemplate_id, :vrowner_bookings, photos: [])
  end
end
