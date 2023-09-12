class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]
  before_action :set_vrental

  def index
    @invoices = policy_scope(Invoice)
    @invoices = @invoices.order(created_at: :asc)
  end

  def show
    authorize @invoice
    @invoice_statements = @invoice.statements.order(start_date: :asc)
    @vrowner = @vrental.vrowner

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: [@vrental.name, @vrowner].join('-'), # filename: "Posts: #{@posts.count}"
               template: "invoices/show",
               header: {
                right: "#{t("page")} [page] #{t("of")} [topage]",
                center: @invoice.date.present? ? l(@invoice.date, format: :long) : '',
                font_size: 9,
                spacing: 5
               },
               formats: [:html],
               disposition: :inline,
               page_size: 'A4',
               dpi: '75',
               zoom: 1,
               layout: 'pdf',
               margin:  {   top:    20,
                            bottom: 30,
                            left:   10,
                            right:  10},
              footer: {
                content: render_to_string(
                  'shared/invoice_footer'
                )}
      end
    end
  end

  def new
    @invoice = Invoice.new
    authorize @invoice
  end

  def edit
    authorize @invoice
  end

  def create
    @invoice = Invoice.new(invoice_params)
    authorize @invoice
    @invoice.vrental = @vrental

    statement_ids = params[:invoice][:statement_ids]
    Statement.where(id: statement_ids).update_all(invoice_id: @invoice.id)

    if @invoice.save
      redirect_to vrental_statements_path(@vrental), notice: 'Has creat la factura.'
    else
      puts "the invoice errors: #{@invoice.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @invoice

    if @invoice.update(invoice_params)
      redirect_to vrental_invoices_path, notice: 'Has actualitzat la factura.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @invoice
    @invoice.destroy
    redirect_to vrental_invoices_path, notice: 'Has esborrat la factura.'
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
  end

  def invoice_params
    params.require(:invoice).permit(:date, :location, :number, :vrental_id, statement_ids: [])
  end
end
