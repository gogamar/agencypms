class StatementsController < ApplicationController
  before_action :set_statement, only: [:show, :edit, :update, :destroy]
  before_action :set_vrental

  def index
    @statements = policy_scope(Statement)
  end

  def show
    authorize @statement
    @total_rent_charges = @statement.total_rent_charges
    @agency_commission = @statement.agency_commission
    @agency_commission_vat = @statement.agency_commission_vat
  end

  def new
    statement_number = @vrental.statements.length + 1
    @statement = Statement.new(ref_number: "#{statement_number}_#{@vrental.id}")
    authorize @statement
  end

  def edit
    authorize @statement
  end

  def create
    @statement = Statement.new(statement_params)
    authorize @statement
    @statement.vrental = @vrental
    if @statement.save
      redirect_to vrental_statements_path, notice: "Has creat una liqudació nova."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @statement
    if @statement.update(statement_params)
      redirect_to vrental_statements_path, notice: 'Has actualitzat la liquidació.'
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
    params.require(:statement).permit(:start_date, :end_date, :date, :location, :ref_number, :vrental_id, :invoice_id, expense_ids: [])
  end
end
