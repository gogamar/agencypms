class ContractsController < ApplicationController
  require 'date'
  before_action :set_contract, only: [:show, :edit, :update, :destroy, :preview]
  before_action :set_realestate, only: [ :new, :create, :edit, :update ]

  def index
    all_contracts = policy_scope(Contract)
    @pagy, @contracts = pagy(all_contracts, page: params[:page], items: 10)
  end

  def list
    @contracts = policy_scope(Contract).includes(:realestate)
    @contracts = @contracts.where("DATE_PART('year', signdate) = ?", params[:year]) if params[:year].present?
    @contracts = @contracts.where(realestate_id: params[:realestate_id]) if params[:realestate_id].present?
    @contracts = @contracts.order("#{params[:column]} #{params[:direction]}")
    @pagy, @contracts = pagy(@contracts, page: params[:page], items: 10)
    render(partial: 'contracts', locals: { contracts: @contracts })
  end

  def show
    authorize @contract
    @rstemplates = Rstemplate.all
    @contracts = Contract.all
    @seller = @contract.realestate.seller
    @buyer = @contract.buyer
    @realestate = @contract.realestate
    @rstemplate = @contract.rstemplate

    details = {
      data_firma: @contract.signdate.present? ? l(@contract.signdate, format: :long) : '',
      lloc_firma: @contract.place.present? ? @contract.place : '',
      preu: @contract.price.present? ? format("%.2f",@contract.price) : '',
      preu_text: @contract.pricetext.present? ? @contract.pricetext : '',
      clausula_adicional: @contract.contentarea.to_s,
      venedor: @realestate.seller.present? && @realestate.seller.fullname.present? ? @realestate.seller.fullname : '',
      dni_venedor: @realestate.seller.present? && @realestate.seller.document.present? ? @realestate.seller.document : '',
      adr_venedor: @realestate.seller.present? && @realestate.seller.address.present? ? @realestate.seller.address : '',
      email_venedor: @realestate.seller.present? && @realestate.seller.email.present? ? @realestate.seller.email : '',
      tel_venedor: @realestate.seller.present? && @realestate.seller.phone.present? ? @realestate.seller.phone : '',
      compte_venedor: @realestate.seller.present? && @realestate.seller.account.present? ? @realestate.seller.account : '',
      comprador: @contract.buyer.present? && @contract.buyer.fullname.present? ? @contract.buyer.fullname : '',
      dni_comprador: @contract.buyer.present? && @contract.buyer.document.present? ? @contract.buyer.document : '',
      adr_comprador: @contract.buyer.present? && @contract.buyer.address.present? ? @contract.buyer.address : '',
      email_comprador: @contract.buyer.present? && @contract.buyer.email.present? ? @contract.buyer.email : '',
      tel_comprador: @contract.buyer.present? && @contract.buyer.phone.present? ? @contract.buyer.phone : '',
      compte_comprador: @contract.buyer.present? && @contract.buyer.account.present? ? @contract.buyer.account : '',
      adr_immoble: @realestate.address.present? ? @realestate.address : '',
      poblacio_immoble: @realestate.city.present? ? @realestate.city : '',
      cadastre: @realestate.cadastre.present? ? @realestate.cadastre : '',
      cert_energetic: @realestate.energy.present? ? @realestate.energy : '',
      descripcio: @realestate.description.present? ? @realestate.description : '',
      oficina_registre: @realestate.registrar.present? ? @realestate.registrar : '',
      tom: @realestate.volume.present? ? @realestate.volume : '',
      llibre: @realestate.book.present? ? @realestate.book : '',
      foli: @realestate.sheet.present? ? @realestate.sheet : '',
      num_finca_registre: @realestate.registry.present? ? @realestate.registry : '',
      inscripcio: @realestate.entry.present? ? @realestate.entry : '',
      carregues: @realestate.charges.present? ? @realestate.charges : '',
      cedula: @realestate.habitability.present? ? @realestate.habitability : '',
      data_cedula: @realestate.hab_date.present? ? l(@realestate.hab_date, format: :long) : '',
      arres: @contract.down_payment.present? ? format("%.2f",@contract.down_payment) : ''
    }

    body = @rstemplate.text.to_s

    @rscontrato = Contract.parse_template(body, details)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: [@realestate.address, @seller].join('-'), # filename: "Posts: #{@posts.count}"
          template: "contracts/show",
          formats: [:html],
          disposition: :inline,
          page_size: 'A4',
          dpi: '75',
          zoom: 1,
          layout: 'pdf',
          margin:  {   top:    10,
                        bottom: 20,
                        left:   15,
                        right:  15},
          footer: { right: "#{t("page")} [page] #{t("of")} [topage]", center: @contract.signdate.present? ? l(@contract.signdate, format: :long) : '', font_size: 8, spacing: 5}
      end
    end
  end

  def new
    @contract = Contract.new
    authorize @contract
  end

  def edit
    authorize @contract
  end

  def create
    @contract = Contract.new(contract_params)
    @contract.realestate = @realestate
    authorize @contract
    if @contract.save
      redirect_to contracts_path, notice: "Has creat el contracte per a #{@realestate.address}."
    else
      render :new
    end
  end

  def update
    @contract.realestate = @realestate
    authorize @contract
    if @contract.update(contract_params)
      redirect_to contracts_path, notice: 'Has actualitzat el contracte.'
    else
      render :edit
    end
  end

  def destroy
    authorize @contract
    @contract.destroy
    redirect_to contracts_url, notice: "Has esborrat el contracte del #{@contract.realestate.address}."
  end

  private

  def set_contract
    @contract = Contract.find(params[:id])
  end

  def set_realestate
    @realestate = Realestate.find(params[:realestate_id])
  end

  def contract_params
    params.require(:contract).permit(:signdate, :place, :price, :pricetext, :down_payment, :realestate_id, :buyer_id, :rstemplate_id, :contentarea, photos: [])
  end
end
