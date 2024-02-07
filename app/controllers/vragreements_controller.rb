class VragreementsController < ApplicationController
  require 'date'
  require "base64"
  before_action :set_vragreement, only: [:show, :edit, :update, :destroy, :sign_contract ]
  before_action :set_vrental, only: [ :new, :create, :edit, :update, :sign_contract ]

  def index
    if params[:vrental_id].present?
      @vrental = Vrental.friendly.find(params[:vrental_id])
      @years_possible_contract = @vrental.years_possible_contract
    end
    active_vragreements = policy_scope(Vragreement)
    if active_vragreements.present?
      active_vragreements = active_vragreements.includes(:vrental).where.not('vrental.status' => "inactive")
      active_vragreements = active_vragreements.where(vrental_id: params[:immoble]) if params[:immoble].present?
      active_vragreements = active_vragreements.order(created_at: :desc)
      @pagy, @vragreements = pagy(active_vragreements, page: params[:page], items: 10)
    end
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
    @vrentaltemplates = Vrentaltemplate.all
    @vragreements = Vragreement.all
    @owner = @vragreement.vrental.owner
    @vrental = @vragreement.vrental
    @vrates = @vrental.rates.where.not(priceweek: nil).where("extract(year from firstnight) = ?", @vragreement.year).order(:firstnight)

    contract_rates = render_to_string(partial: 'rates')
    @vrcontrato = @vragreement.generate_contract_body(contract_rates)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: [@vrental.address, @owner].join('-'),
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
                  'shared/pdf_header',
                  locals: { resource: @vragreement }
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

    @years_possible_contract = @vrental.years_possible_contract

    @year = params[:year].to_i
    @rates = @vrental.future_rates.where("extract(year from firstnight) = ?", @year).order(:firstnight)
    @contract_start_date = @rates.first.firstnight if @rates.present?
    @contract_end_date = @rates.last.lastnight if @rates.present?
    @place = @vrental.office.city if @vrental.office
    @vrentaltemplates = Vrentaltemplate.where(language: @vrental.owner.present? ? @vrental.owner.language : I18n.default_locale)
    @default_template = @vrentaltemplates.max_by do |template|
      template.vragreements.count
    end
    @vragreement.attributes = {
      start_date: @contract_start_date,
      end_date: @contract_end_date,
      year: params[:year].to_i,
      vrentaltemplate: @default_template,
      signdate: Date.today,
      place: @place,
      status: 'pending',
      owner_bookings: t("owner_bookings_default", email: @vrental.office.email)
    }
    @years_vragreement_exists = @vrental.vragreements.pluck(:year)
    next_three_years = [Date.today.year, Date.today.year + 1, Date.today.year + 2]
    merged_arrays = next_three_years + @years_vragreement_exists
    @years_vragreement_missing = merged_arrays.select { |year| merged_arrays.count(year) == 1 }
    @vrentaltemplates = policy_scope(Vrentaltemplate)
  end

  def copy
    authorize(@vragreement = Vragreement.new)

    @source = Vragreement.find(params[:id])
    @vrental = @source.vrental
    @years_vragreement_exists = @vrental.vragreements.pluck(:year)
    @vrental.copy_rates_to_next_year(@source.year)

    @vragreement.attributes = {
      year: @source.year + 1,
      vrentaltemplate: @source.vrentaltemplate,
      vrental: @vrental,
      signdate: Date.today,
      place: @source.place,
      status: 'pending',
      owner_bookings: t("owner_bookings_default", email: @vrental.office.email)
    }

    @vrates = @vrental.rates.where("extract(year from firstnight) = ?", @vragreement.year).order(:firstnight)
    @vragreement.start_date = @vrates.first.firstnight
    @vragreement.end_date = @vrates.last.lastnight + 1.day

    authorize @vragreement

    if @vragreement.save
      redirect_to edit_vrental_vragreement_path(@vrental, @vragreement), notice: "S'ha creat una còpia del contracte per #{@vragreement.year}."
    else
      # Handle validation errors or other errors if needed
      render :new
    end
  end

  def edit
    @vrentaltemplates = policy_scope(Vrentaltemplate)
    @rates = @vrental.rates.where("extract(year from firstnight) = ?", @vragreement.year).order(:firstnight)
  end

  def create
    @vragreement = Vragreement.new(vragreement_params)
    @vragreement.vrental = @vrental
    authorize @vragreement
    @vragreement.company = @vrental.office.company || @company
    if @vragreement.save
      redirect_to vrental_vragreements_path(@vrental), notice: "Has creat el contracte per #{@vrental.name}."
    else
      render :new
    end
  end

  def sign_contract
    signature_data = params[:vragreement][:signature_data]
    if signature_data.present?
      encoded_image = signature_data.split(',')[1]
      decoded_image = Base64.decode64(encoded_image)
      signature_blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(decoded_image),
        filename: 'signature.png',
        content_type: 'image/png'
      )
      @vragreement.signature_image.attach(signature_blob)
      @vragreement.signatory = current_user.id
      @vragreement.signdate = @vragreement.signature_image.created_at
    end
    @vragreement.save
    redirect_to vrental_vragreement_path(@vrental, @vragreement), notice: t("contract_signed")
  end

  def update
    @vragreement.vrental = @vrental
    if @vragreement.update(vragreement_params)
      redirect_to vrental_vragreement_path(@vrental, @vragreement), notice: 'Has actualitzat el contracte.'
    else
      render :edit
    end
  end

  def destroy
    @vrental = Vrental.friendly.find(params[:vrental_id]) if params[:vrental_id].present?
    @vragreement.destroy

    if @vrental
      redirect_to vrental_vragreements_path(@vrental), notice: "Has esborrat el contracte del #{@vragreement.vrental.name}."
    else
      redirect_to vragreements_path, notice: "Has esborrat el contracte."
    end
  end

  private

  def set_vragreement
    @vragreement = Vragreement.find(params[:id])
    authorize @vragreement
  end
  def set_vrental
    @vrental = Vrental.friendly.find(params[:vrental_id])
  end
  def set_owner
    @owner = Owner.find(params[:owner_id])
  end

  def set_vrentaltemplate
    @vrentaltemplate = @vragreement.vrentaltemplate
  end

  # Only allow a list of trusted parameters through.
  def vragreement_params
    params.require(:vragreement).permit(:status, :year, :signdate, :place, :start_date, :end_date, :vrental_id, :signature_image, :signatory, :vrentaltemplate_id, :owner_bookings, :company_id, photos: [])
  end
end
