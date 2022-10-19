class VragreementsController < ApplicationController
  require 'date'

  before_action :set_vragreement, only: [:show, :edit, :update, :destroy, :preview]
  before_action :set_vrental, only: [:new, :create, :edit]
  # before_action :set_vrentaltemplate, only: [:show, :index, :new, :create]
  # before_action :set_vrowner, only: [:show, :new, :create]
  # before_action :set_renter, only: [:show, :index, :new, :create]

  # GET /vragreements
  def index
    @vragreements = Vragreement.all
    # @vrental = @vragreement.rental

    # @vragreements = Agreement.where(vrentaltemplate_id: @vrentaltemplate, vrowner_id: @vrowner, renter_id: @renter, vrental_id: @vrental)
  end

  # GET /vragreements/1
  def show
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
        # Rails 6:
        # render pdf: "Contracte: #{@vrental.address}",
        #        template: "vragreements/show.html.erb",
        #        # wkhtmltopdf: '/usr/local/bin/wkhtmltopdf',
        #        layout: "pdf",
        #        orientation: "Portrait", # Landscape
        #        page_size: 'A4',
        #        dpi: '72',
        #        zoom: 1.25,
        #        disposition: 'inline',
        #        margin:  {top: 40, bottom: 20, left: 20, right: 20},
        #        header: {
        #         # content: render_to_string(template: 'vragreements/header.html.erb', layout: 'header_layout'),
        #         content: render_to_string(template: 'vragreements/header.html.erb', layout: 'header_layout'),
        #         spacing: 10
        #        },
        #       footer: { right: 'Pàgina [page] de [topage]',
        #         center: @vragreement.signdate,
        #         font_size: 10}
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

  # GET /vragreements/new
  def new
    @vrental = Vrental.find(params[:vrental_id])
    @vragreement = Vragreement.new
  end

  # GET /vragreements/1/edit
  def edit
  end

  # POST /vragreements
  def create
    @vragreement = Vragreement.new(vragreement_params)
    @vrental = Vrental.find(params[:vrental_id])
    @vragreement.vrental = @vrental
    if @vragreement.save
      redirect_to vrental_path(@vragreement.vrental), notice: 'Has creat el contracte.'
    else
      render :new
    end
  end

  # PATCH/PUT /vragreements/1
  def update
    @vrental = Vrental.find(params[:vrental_id])
    @vragreement.vrental = @vrental
    if @vragreement.update(vragreement_params)
      redirect_to vragreements_path, notice: 'Has actualitzat el contracte.'
    else
      render :edit
    end
  end

  # DELETE /vragreements/1
  def destroy
    @vragreement.destroy
    redirect_to vragreements_url, notice: 'Has esborrat el contracte.'
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
