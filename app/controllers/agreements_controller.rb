class AgreementsController < ApplicationController
  require 'date'
  before_action :set_agreement, only: [:show, :edit, :update, :destroy, :preview]
  before_action :set_rental, only: [ :new, :create, :edit, :update ]

  def index
    all_agreements = policy_scope(Agreement)
    @pagy, @agreements = pagy(all_agreements, page: params[:page], items: 10)
  end

  def list
    @agreements = policy_scope(Agreement).includes(:rental)
    @agreements = @agreements.where("DATE_PART('year', signdate) = ?", params[:year]) if params[:year].present?
    @agreements = @agreements.where(rental_id: params[:rental_id]) if params[:rental_id].present?
    @agreements = @agreements.order("#{params[:column]} #{params[:direction]}")
    @pagy, @agreements = pagy(@agreements, page: params[:page], items: 10)
    render(partial: 'agreements', locals: { agreements: @agreements })
  end

  def show
    authorize @agreement
    @rentaltemplates = Rentaltemplate.all
    @agreements = Agreement.all
    @owner = @agreement.rental.owner
    @renter = @agreement.renter
    @rental = @agreement.rental
    @rentaltemplate = @agreement.rentaltemplate

    details = {
      data_firma: @agreement.signdate.present? ? l(@agreement.signdate, format: :long) : '',
      lloc_firma: @agreement.place.present? ? @agreement.place : '',
      data_inici: @agreement.start_date.present? ? l(@agreement.start_date, format: :long) : '',
      data_fi: @agreement.end_date.present? ? l(@agreement.end_date, format: :long) : '',
      durada: @agreement.duration.present? ? @agreement.duration : '',
      preu: @agreement.price.present? ? format("%.2f",@agreement.price) : '',
      preu_text: @agreement.pricetext.present? ? @agreement.pricetext : '',
      fiança: @agreement.deposit.present? ? format("%.2f",@agreement.deposit) : '',
      clausula_adicional: @agreement.contentarea.to_s,
      propietari: @rental.owner.present? && @rental.owner.fullname.present? ? @rental.owner.fullname : '',
      dni_propietari: @rental.owner.present? && @rental.owner.document.present? ? @rental.owner.document : '',
      adr_propietari: @rental.owner.present? && @rental.owner.address.present? ? @rental.owner.address : '',
      email_propietari: @rental.owner.present? && @rental.owner.email.present? ? @rental.owner.email : '',
      tel_propietari: @rental.owner.present? && @rental.owner.phone.present? ? @rental.owner.phone : '',
      compte_propietari: @rental.owner.present? && @rental.owner.account.present? ? @rental.owner.account : '',
      adr_immoble: @rental.address.present? ? @rental.address : '',
      cadastre: @rental.cadastre.present? ? @rental.cadastre : '',
      cert_energetic: @rental.energy.present? ? @rental.energy : '',
      descripcio: @rental_description.to_s
    }

    body = @rentaltemplate.text.to_s

    @contrato = Agreement.parse_template(body, details)

    respond_to do |format|
      format.html
      format.pdf do
        # Rails 7
        render pdf: [@rental.address, @owner].join('-'), # filename: "Posts: #{@posts.count}"
          template: "agreements/show",
          formats: [:html],
          disposition: :inline,
          page_size: 'A4',
          dpi: '72',
          zoom: 1.25,
          layout: 'pdf',
          margin:  {   top:    10,
                        bottom: 20,
                        left:   15,
                        right:  15},

          footer: { right: "#{t("page")} [page] #{t("of")} [topage]", center: @agreement.signdate.present? ? l(@agreement.signdate, format: :long) : '', font_size: 8, spacing: 5}
        # end Rails 7
      end
    end
  end

  def new
    @agreement = Agreement.new
    authorize @agreement
  end

  def edit
    authorize @agreement
  end

  def create
    @agreement = Agreement.new(agreement_params)
    @agreement.rental = @rental
    authorize @agreement
    if @agreement.save
      redirect_to agreements_path, notice: "Has creat el contracte per a #{@rental.address}."
    else
      render :new
    end
  end

  def update
    @agreement.rental = @rental
    authorize @agreement
    if @agreement.update(agreement_params)
      redirect_to agreements_path, notice: 'Has actualitzat el contracte.'
    else
      render :edit
    end
  end

  def destroy
    authorize @agreement
    @agreement.destroy
    redirect_to agreements_url, notice: "Has esborrat el contracte del #{@agreement.rental.address}."
  end

  private

  def set_agreement
    @agreement = Agreement.find(params[:id])
  end

  def set_rental
    @rental = Rental.find(params[:rental_id])
  end

  def agreement_params
    params.require(:agreement).permit(:signdate, :place, :start_date, :duration, :end_date, :price, :pricetext, :deposit, :rental_id, :renter_id, :rentaltemplate_id, :contentarea, photos: [])
  end
end
