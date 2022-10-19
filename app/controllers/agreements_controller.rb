class AgreementsController < ApplicationController
  require 'date'

  before_action :set_agreement, only: [:show, :edit, :update, :destroy, :preview]
  # before_action :set_rental, only: [:show, :index, :new, :create]
  # before_action :set_rentaltemplate, only: [:show, :index, :new, :create]
  # before_action :set_owner, only: [:show, :new, :create]
  # before_action :set_renter, only: [:show, :index, :new, :create]
  # On your controller.


  # def download
  #   respond_to do |format|
  #     format.docx do
  #       render docx: 'download', filename: 'agreement.docx'
  #     end
  #   end
  # end

  # GET /agreements
  def index
    @agreements = Agreement.all
    # @agreements = Agreement.where(rentaltemplate_id: @rentaltemplate, owner_id: @owner, renter_id: @renter, rental_id: @rental)
  end

  # GET /agreements/1
  def show
    @rentaltemplates = Rentaltemplate.all
    # @rentaltemplate = Rentaltemplate.where(title: "rental")[0] # use some other way to find this because this one is an array
    @owner = @agreement.rental.owner
    @renter = @agreement.renter
    @rental = @agreement.rental

    @rentaltemplate = @agreement.rentaltemplate
    details = {
      propietari: @rental.owner.fullname.present? ? @rental.owner.fullname : '',
      immoADR: @rental.address.present? ? @rental.address : '',
      lloc: @agreement.place.present? ? @agreement.place : '',
      propDNI: @rental.owner.document.present? ? @rental.owner.document : '',
      propADR: @rental.owner.address.present? ? @rental.owner.address : '',
      inquili: @renter.fullname.present? ? @renter.fullname : '<',
      inqDNI: @renter.document.present? ? @renter.document : '',
      inqADR: @renter.address.present? ? @renter.address : '',
      preuNUM: @agreement.price.present? ? @agreement.price.to_s : '',
      preuTEXT: @agreement.pricetext.present? ? @agreement.pricetext : '',
      durada: @agreement.duration.present? ? @agreement.duration : '',
      dataINI: @agreement.start_date.present? ? l(@agreement.start_date, format: :long) : '',
      dataFI: @agreement.end_date.present? ? l(@agreement.end_date, format: :long) : '',
      dataFIRMA: @agreement.signdate.present? ? l(@agreement.signdate, format: :long) : '',
      cadastre: @rental.cadastre.present? ? @rental.cadastre : '',
      certENE: @rental.energy.present? ? @rental.energy : '',
      municipi: @rental.city.present? ? @rental.city : '',
      descripcio: @rental.description.present? ? @rental.description : ''
    }
    body = @rentaltemplate.text.to_s

    @contrato = Agreement.parse_template(body, details)

    respond_to do |format|
      format.html
      format.pdf do
        # Rails 6:
        # render pdf: "Contracte: #{@rental.address}",
        #        template: "agreements/show.html.erb",
        #        # wkhtmltopdf: '/usr/local/bin/wkhtmltopdf',
        #        layout: "pdf",
        #        orientation: "Portrait", # Landscape
        #        page_size: 'A4',
        #        dpi: '72',
        #        zoom: 1.25,
        #        disposition: 'inline',
        #        margin:  {top: 40, bottom: 20, left: 20, right: 20},
        #        header: {
        #         # content: render_to_string(template: 'agreements/header.html.erb', layout: 'header_layout'),
        #         content: render_to_string(template: 'agreements/header.html.erb', layout: 'header_layout'),
        #         spacing: 10
        #        },
        #       footer: { right: 'Pàgina [page] de [topage]',
        #         center: @agreement.signdate,
        #         font_size: 10}
        # # Rails 7
        render pdf: [@rental.address, @owner].join('-'), # filename: "Posts: #{@posts.count}"
               template: "agreements/show",
               formats: [:html],
               disposition: :inline,
              #  page_size: 'A4',
               dpi: '72',
               zoom: 1.25,
               layout: 'pdf',
               margin:  {   top:    10,
                            bottom: 20,
                            left:   15,
                            right:  15},

               footer: { right: 'Pàgina [page] de [topage]', center: @agreement.signdate.present? ? l(@agreement.signdate, format: :long) : '', font_size: 8, spacing: 5}
        # # end Rails 7
      end
    end
  end

  # GET /agreements/new
  def new
    @agreement = Agreement.new
    # @rental = Rental.find_by(id: params[:rental_id])
    # @owner = @rental.owner
  end

  # GET /agreements/1/edit
  def edit
  end

  # POST /agreements
  def create
    @agreement = Agreement.new(agreement_params)
    if @agreement.save
      redirect_to @agreement, notice: 'Has creat el contracte.'
    else
      render :new
    end
  end

  # PATCH/PUT /agreements/1
  def update
    if @agreement.update(agreement_params)
      redirect_to @agreement, notice: 'Has actualitzat el contracte.'
    else
      render :edit
    end
  end

  # DELETE /agreements/1
  def destroy
    @agreement.destroy
    redirect_to agreements_url, notice: 'Has esborrat el contracte.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agreement
      @agreement = Agreement.find(params[:id])
    end
    def set_rental
      @rental = Rental.find(params[:rental_id])
    end
    def set_owner
      @owner = Owner.find(params[:owner_id])
    end
    def set_renter
      @renter = Renter.find(params[:renter_id])
    end
    def set_rentaltemplate
      @rentaltemplate = @agreement.rentaltemplate
    end

    # Only allow a list of trusted parameters through.
    def agreement_params
      params.require(:agreement).permit(:signdate, :place, :start_date, :duration, :end_date, :price, :pricetext, :deposit, :rental_id, :renter_id, :rentaltemplate_id, :contentarea, photos: [])
    end
end
