class StatementsController < ApplicationController
  before_action :set_statement, only: [:show, :edit, :update, :destroy]
  before_action :set_vrental

  def index
    @statements = policy_scope(Statement)
    @statements = @vrental.present? ? @vrental.statements.order(created_at: :asc) : @statements.order(created_at: :asc)
    extract_year_sql = Arel.sql('DISTINCT EXTRACT(YEAR FROM start_date)')
    @statement_years = @vrental.statements.select(extract_year_sql).pluck(extract_year_sql).map(&:to_i)
  end

  def show
    authorize @statement
    @statement_bookings = @statement.statement_bookings
    @statement_earnings = @statement.statement_earnings
    @statement_expenses = Expense.where(id: @statement.expense_ids)
    @total_statement_earnings = @statement.total_statement_earnings
    @total_expenses = @statement.total_expenses
    # @total_rent_charges = @statement.total_rent_charges
    @agency_commission = @statement.agency_commission
    @agency_commission_vat = @statement.agency_commission_vat
    @vrowner = @vrental.vrowner

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@vrental.name}, liquidació #{@statement.start_date} - #{@statement.end_date}",
               template: "statements/show",
               header: {
                right: "#{t("page")} [page] #{t("of")} [topage]",
                center: @statement.date.present? ? l(@statement.date, format: :long) : '',
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
               footer: { content: render_to_string(
                          'shared/invoice_footer'
                        )}
      end
    end
  end

  def new
    @statement = Statement.new
    authorize @statement
  end

  def edit
    authorize @statement
  end

  def create
    @statement = Statement.new(statement_params)
    authorize @statement
    @statement.vrental = @vrental
    statement_year = (Date.parse(params[:statement][:start_date])).year
    statements_with_same_year = @vrental.statements.where("EXTRACT(year FROM end_date) = ?", statement_year)
    @statement.ref_number = "#{statements_with_same_year.count + 1}_#{@vrental.name}_#{statement_year}"

    if @statement.save
      redirect_to add_earnings_vrental_statement_path(@vrental, @statement), notice: 'Has creat la liquidació.'
    else
      puts "new statement errors: #{@statement.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def add_earnings
    @statement = Statement.find(params[:id])
    authorize @statement
    @statement_bookings = @statement.statement_bookings
    @statement_earnings = @statement.statement_earnings
  end

  def add_expenses
    @statement = Statement.find(params[:id])
    authorize @statement
  end

  def update
    authorize @statement
    request_context = params[:statement][:request_context] if params[:statement] && params[:statement][:request_context]

    if @statement.update(statement_params)
      if request_context && request_context == 'add_earnings'
        redirect_to add_earnings_vrental_statement_path(@vrental, @statement)
      elsif request_context && request_context == 'add_expenses'
        @statement.earnings.update_all(statement_id: nil)
        @statement.statement_earnings.update_all(statement_id: @statement.id)
        redirect_to add_expenses_vrental_statement_path(@vrental, @statement)
      else
        redirect_to vrental_statements_path, notice: 'Has actualitzat la liquidació.'
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @statement

    if !@statement.invoice || (@statement.invoice && Date.current == @statement.invoice.created_at.to_date)
      @statement.destroy
      redirect_to vrental_statements_path, notice: 'Has esborrat la liquidació.'
    else
      puts "statement errors: #{@statement.errors.full_messages}"
      redirect_to vrental_statements_path, notice: 'No pots esborrar aquesta liquidació perquè ja ha passat més d\'un dia des de la creació de la factura.'
    end
  end

  private

  def set_statement
    @statement = Statement.find(params[:id])
  end

  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
  end

  def statement_params
    params.require(:statement).permit(:start_date, :end_date, :date, :location, :ref_number, :vrental_id, :invoice_id, expense_ids: [])
  end
end
