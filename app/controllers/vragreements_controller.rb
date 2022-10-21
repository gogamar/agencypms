class VragreementsController < ApplicationController
  require 'date'
  before_action :set_vragreement, only: [:show, :edit, :update, :destroy ]
  before_action :set_vrental, only: [ :new, :create, :edit, :update ]

  def index
    @vragreements = policy_scope(Vragreement)
  end

  # GET /vragreements/1
  def show
    authorize @vragreement
    @vrentaltemplates = Vrentaltemplate.all
    @vragreements = Vragreement.all
    # @vrentaltemplate = Rentaltemplate.where(title: "vrental")[0] # use some other way to find this because this one is an array
    @vrowner = @vragreement.vrental.vrowner
    # @vrowners = Vrowner.sort_by(:fullname).all
    @vrental = @vragreement.vrental
    @vrates = Rate.where(vrental_id: @vrental).order(:firstnight)
    @contractrates = render_to_string(partial: 'rates')
    @features = Feature.where(vrental_id: @vrental).pluck(:name).map {|str| t("#{str}")}.join(", ").capitalize()
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
      propietari: @vrental.vrowner.fullname.present? ? @vrental.vrowner.fullname : '',
      dni_propietari: @vrental.vrowner.document.present? ? @vrental.vrowner.document : '',
      adr_propietari: @vrental.vrowner.address.present? ? @vrental.vrowner.address : '',
      email_propietari: @vrental.vrowner.email.present? ? @vrental.vrowner.email : '',
      tel_propietari: @vrental.vrowner.phone.present? ? @vrental.vrowner.phone : '',
      compte_propietari: @vrental.vrowner.phone.present? ? @vrental.vrowner.phone : '',
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
      carac_immoble: @features.to_s,
      comissio: format("%.2f", @vrental.commission.to_f * 100),
      clausula_adicional: @vragreement.clause.to_s
    }

    body = @vrentaltemplate.text.to_s
    @vrcontrato = Vragreement.parse_template(body, details)

    respond_to do |format|
      format.html
      format.pdf do
        # # Rails 7
        render pdf: [@vrental.address, @vrowner].join('-'), # filename: "Posts: #{@posts.count}"
               template: "vragreements/show",
               formats: [:html],
               disposition: :inline,
               page_size: 'A4',
               dpi: '300',
               zoom: 1,
               layout: 'pdf',
               margin:  {   top:    10,
                            bottom: 20,
                            left:   15,
                            right:  15},

               footer: { right: 'Pàgina [page] de [topage]', center: @vragreement.signdate.present? ? l(@vragreement.signdate, format: :long) : '', font_size: 9, spacing: 5}
        # # end Rails 7
      end
    end
  end

  def new
    @vragreement = Vragreement.new
    authorize @vragreement
  end

  # GET /vragreements/1/edit
  def edit
    authorize @vragreement
  end

  # POST /vragreements
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

  # PATCH/PUT /vragreements/1
  def update
    @vragreement.vrental = @vrental
    authorize @vragreement
    if @vragreement.update(vragreement_params)
      redirect_to vragreements_path, notice: 'Has actualitzat el contracte.'
    else
      render :edit
    end
  end

  # DELETE /vragreements/1
  def destroy
    authorize @vragreement
    @vragreement.destroy
    redirect_to vragreements_path, notice: "Has esborrat el contracte del #{@vragreement.vrental.name}."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
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
    params.require(:vragreement).permit(:signdate, :place, :start_date, :end_date, :vrental_id, :vrentaltemplate_id, :vrowner_bookings, photos: [])
  end
end
