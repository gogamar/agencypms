class StatementsController < ApplicationController
  before_action :set_statement, only: [:show, :edit, :update, :destroy]
  before_action :set_vrental

  def index
    @statements = policy_scope(Statement)
    @statements = @vrental.present? ? @vrental.statements.order(created_at: :asc) : @statements.order(created_at: :asc)
    total_amount = 0
    @statements.each do |statement|
      total_amount += statement.statement_earnings.sum(:amount)
    end
    @total_statements = total_amount
  end

  def show
    authorize @statement
    @statement_bookings = @statement.statement_bookings
    @statement_earnings = @statement.statement_earnings
    @total_statement_earnings = @statement.total_statement_earnings
    @total_expenses = @statement.total_expenses
    # @total_rent_charges = @statement.total_rent_charges
    @agency_commission = @statement.agency_commission
    @agency_commission_vat = @statement.agency_commission_vat
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
      error_messages = @statement.errors.full_messages.join(', ')
      flash[:alert] = "#{error_messages}"
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
    request_context = params[:statement][:request_context]
    if @statement.update(statement_params)
      if request_context && request_context == 'add_earnings'
        redirect_to add_earnings_vrental_statement_path(@vrental, @statement)
      elsif request_context && request_context == 'add_expenses'
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
    @statement.destroy
    redirect_to vrental_statements_path, notice: 'Has esborrat la liquidació.'
  end

  private

  def set_statement
    @statement = Statement.find(params[:id])
  end

  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
  end

  def statement_params
    params.require(:statement).permit(:start_date, :end_date, :date, :location, :ref_number, :vrental_id, :invoice_id, expense_ids: [], earning_attributes: [:id, :amount, :description, :discount, :statement_id, :_destroy])
  end
end
