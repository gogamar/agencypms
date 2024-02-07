class StatementsController < ApplicationController
  before_action :set_statement, only: [:show, :edit, :update, :destroy]
  before_action :set_vrental

  def index
    @statements = policy_scope(Statement)
    @statements = @vrental.present? ? @vrental.statements.order(start_date: :asc) : @statements.order(start_date: :asc)
    @booking_years = @vrental.bookings.pluck(:checkin).map(&:year).uniq.sort.reverse
    @selected_year = @booking_years.first
    @last_year_statements = @vrental.statements.where("EXTRACT(year FROM end_date) = ?", Date.current.year - 1)
    @last_year = Date.current.year - 1
  end

  def show
    authorize @statement
    @statement_bookings = @statement.statement_bookings
    @confirmed_statement_earnings = @statement.confirmed_statement_earnings
    @statement_expenses = Expense.where(id: @statement.expense_ids)
    @statement_expenses_owner = @statement_expenses.where(expense_type: 'owner')
    @statement_expenses_agency = @statement_expenses.where(expense_type: 'agency')
    @total_statement_expenses_owner = @statement.total_expenses_owner
    @total_statement_earnings = @statement.total_statement_earnings
    @agency_commission = @statement.agency_commission
    @agency_commission_vat = @statement.agency_commission_vat
    @owner = @vrental.owner

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@vrental.name}, liquidació #{@statement.start_date} - #{@statement.end_date}",
               template: "statements/show",
               margin:  {
                top: 70,
                bottom: 25,
                left: 10,
                right: 10},
              header: {
                font_size: 9,
                spacing: 30,
                content: render_to_string(
                  'shared/pdf_header',
                  locals: { resource: @statement }
                )
               },
               formats: [:html],
               disposition: :inline,
               page_size: 'A4',
               page_breaks: true,
               dpi: '75',
               zoom: 1,
               layout: 'pdf',
               footer: {
                font_size: 9,
                spacing: 5,
                right: "#{t("page")} [page] #{t("of")} [topage]",
                left: @statement.date.present? ? l(@statement.date, format: :long) : ''
              }
      end
    end
  end

  def new
    @statement = Statement.new
    authorize @statement
    @ref_number = "#{@vrental.statements.where("EXTRACT(year FROM end_date) = ?", statement_year).count + 1}_#{@vrental.name}_#{statement_year}"
  end

  def edit
    authorize @statement
  end

  def create
    @statement = Statement.new(statement_params)
    authorize @statement
    @statement.vrental = @vrental
    @statement.company = @vrental.office.company || @company
    statement_year = (Date.parse(params[:statement][:start_date])).year
    statements_same_year = @vrental.statements.where("EXTRACT(year FROM end_date) = ?", statement_year)
    @statement.ref_number = "#{statements_same_year.count + 1}_#{@vrental.name}_#{statement_year}"

    if @statement.save
      @statement.statement_earnings.update_all(statement_id: @statement.id)

      flash.now[:notice] = "Has creat una nova liquidació."
      redirect_to vrental_statements_path
    else
      flash[:alert] = @statement.errors.full_messages

    end
  end

  def update
    authorize @statement

    if @statement.update(statement_params)
      @statement.earnings.update_all(statement_id: nil)
      @statement.statement_earnings.update_all(statement_id: @statement.id)
      redirect_to vrental_statements_path, notice: 'Has actualitzat la liquidació.'
    else
      flash[:alert] = @statement.errors.full_messages
    end
  end

  def destroy
    authorize @statement

    if !@statement.invoice || (@statement.invoice && Date.current == @statement.invoice.created_at.to_date)
      @statement.destroy
      redirect_to vrental_statements_path, notice: 'Has esborrat la liquidació.'
    else
      redirect_to vrental_statements_path, notice: 'No pots esborrar aquesta liquidació perquè ja ha passat més d\'un dia des de la creació de la factura.'
    end
  end

  private

  def set_statement
    @statement = Statement.find(params[:id])
  end

  def set_vrental
    @vrental = Vrental.friendly.find(params[:vrental_id])
  end

  def statement_params
    params.require(:statement).permit(:start_date, :end_date, :date, :location, :ref_number, :vrental_id, :company_id, :invoice_id, expense_ids: [])
  end
end
