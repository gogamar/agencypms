class VragreementsController < ApplicationController
  require 'date'
  before_action :set_vragreement, only: [:show, :edit, :update, :destroy ]
  before_action :set_vrental, only: [ :new, :create, :edit, :update ]

  def index
    active_vragreements = policy_scope(Vragreement).includes(:vrental).where.not('vrental.status' => "inactive")
    active_vragreements = active_vragreements.where(vrental_id: params[:immoble]) if params[:immoble].present?
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
    @contractrates = render_to_string(partial: 'rates')
    @vrental_features = @vrental.features.pluck(:name).map {|str| t("#{str}")}.sort_by {|t| t }.join(", ").capitalize()
    @vrentaltemplate = @vragreement.vrentaltemplate
    @vrental_description =
        case @vrentaltemplate.language
        when "ca"
          @vrental.description
        when "es"
          @vrental.description_es
        when "fr"
          @vrental.description_fr
        when "en"
          @vrental.description_en
        else
          ""
        end

    details = {
      data_firma: @vragreement.signdate.present? ? l(@vragreement.signdate, format: :long) : '',
      lloc_firma: @vragreement.place.present? ? @vragreement.place : '',
      propietari: @vrental.vrowner.present? && @vrental.vrowner.fullname.present? ? @vrental.vrowner.fullname : '',
      dni_propietari: @vrental.vrowner.present? && @vrental.vrowner.document.present? ? @vrental.vrowner.document : '',
      adr_propietari: @vrental.vrowner.present? && @vrental.vrowner.address.present? ? @vrental.vrowner.address : '',
      email_propietari: @vrental.vrowner.present? && @vrental.vrowner.email.present? ? @vrental.vrowner.email : '',
      tel_propietari: @vrental.vrowner.present? && @vrental.vrowner.phone.present? ? @vrental.vrowner.phone : '',
      compte_propietari: @vrental.vrowner.present? && @vrental.vrowner.account.present? ? @vrental.vrowner.account : '',
      nom_immoble: @vrental.name.present? ? @vrental.name.upcase() : '',
      adr_immoble: @vrental.address.present? ? @vrental.address : '',
      cadastre: @vrental.cadastre.present? ? @vrental.cadastre : '',
      cedula: @vrental.habitability.present? ? @vrental.habitability : '',
      num_HUT: @vrental.licence.present? ? @vrental.licence : '',
      descripcio: @vrental_description.to_s,
      data_inici: @vragreement.start_date.present? ? l(@vragreement.start_date, format: :long) : '',
      data_fi: @vragreement.end_date.present? ? l(@vragreement.end_date, format: :long) : '',
      tarifes: @contractrates,
      reserves_propietari: @vragreement.vrowner_bookings,
      carac_immoble: @vrental_features.to_s,
      comissio: format("%.2f", @vrental.commission.to_f * 100),
      clausula_adicional: @vragreement.clause.to_s
    }

    body = @vrentaltemplate.text.to_s
    @vrcontrato = Vragreement.parse_template(body, details)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: [@vrental.address, @vrowner].join('-'), # filename: "Posts: #{@posts.count}"
               template: "vragreements/show",
               formats: [:html],
               disposition: :inline,
               page_size: 'A4',
               dpi: '75',
               zoom: 1,
               layout: 'pdf',
               margin:  {   top:    20,
                            bottom: 20,
                            left:   10,
                            right:  10},
               footer: { right: "#{t("page")} [page] #{t("of")} [topage]", center: @vragreement.signdate.present? ? l(@vragreement.signdate, format: :long) : '', font_size: 9, spacing: 5 }
      end
    end
  end

  def new
    @vragreement = Vragreement.new
    authorize @vragreement
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
    params.require(:vragreement).permit(:status, :signdate, :place, :start_date, :end_date, :vrental_id, :vrentaltemplate_id, :vrowner_bookings, photos: [])
  end
end
