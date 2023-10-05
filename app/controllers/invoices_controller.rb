class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]
  before_action :set_vrental, except: [:index, :download_all]
  # after_action :cleanup_temp_file, only: [:download_all]

  def index
    @invoices = policy_scope(Invoice)
    @invoices = @invoices.order(number: :asc)
    @total_agency_fees_invoiced = Invoice.all.map(&:agency_total).sum
  end

  def download_all
    invoices = policy_scope(Invoice).order(number: :asc)
    authorize invoices

    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: 'Factures') do |sheet|
      sheet.add_row ['Número', 'Data', 'Immoble', 'HUT', 'Adreça immoble', 'Propietari', 'DNI', 'Adreça Propietari', 'Import', 'IVA', 'Total']

      invoices.each do |invoice|
        sheet.add_row [invoice.number, invoice.date, invoice.vrental.name, invoice.vrental.licence, invoice.vrental.address, invoice.vrental.vrowner&.fullname, invoice.vrental.vrowner&.document, invoice.vrental.vrowner&.address, invoice.agency_commission_total, invoice.agency_vat_total, invoice.agency_total]
      end
    end

    @tmp_file = Tempfile.new('factures_huts.xlsx')
    package.serialize(@tmp_file.path)

    send_file @tmp_file.path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: 'factures_huts.xlsx'
  end

  def show
    authorize @invoice
    @invoice_statements = @invoice.statements.order(start_date: :asc)
    @vrowner = @vrental.vrowner

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@vrental.name}, factura #{@invoice.date.year}/#{@invoice.number}",
                template: "invoices/show",
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
                dpi: '75',
                zoom: 1,
                layout: 'pdf',
                footer: {
                  font_size: 9,
                  spacing: 5,
                  right: "#{t("page")} [page] #{t("of")} [topage]",
                  left: @invoice.date.present? ? l(@invoice.date, format: :long) : ''
                }
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
      redirect_to vrental_statements_path(@vrental), notice: 'Has actualitzat la factura.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @invoice

    if Date.current == @invoice.created_at.to_date
      @invoice.destroy
      redirect_to vrental_invoices_path, notice: 'Has esborrat la factura.'
    else
      redirect_to vrental_invoices_path, alert: 'No pots esborrar aquesta factura perquè no és el mateix dia que la creació.'
    end
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

  def cleanup_temp_file
    sleep(20)
    @tmp_file.close if @tmp_file
    @tmp_file.unlink if @tmp_file
  end
end
