class ExpensesController < ApplicationController
  before_action :set_vrental, except: %i[new create index destroy]
  before_action :set_expense, only: %i[edit update destroy]

  def index
    @expenses = policy_scope(Expense)
    @vrental = Vrental.find(params[:vrental_id]) if params[:vrental_id]
    @expenses = @vrental.present? ? @vrental.expenses.order(created_at: :asc) : @expenses.order(created_at: :asc)
    @total_expenses_agency = @expenses.where(expense_type: 'agency').pluck(:amount)&.sum
    @total_expenses_owner = @expenses.where(expense_type: 'owner').pluck(:amount)&.sum
  end

  def new
    @expense = Expense.new
    authorize @expense
    @vrental = Vrental.find(params[:vrental_id]) if params[:vrental_id]
    @vrentals = policy_scope(Vrental)
  end

  def edit
    authorize @expense
  end

  def create
    @expense = Expense.new(expense_params)
    authorize @expense

    @expense.expense_number = "#{@expense.vrental.expenses.count + 1}-#{@expense.vrental.id}-#{Date.today.year}"

    if @expense.save
      if params[:vrental_id].present?
        @vrental = Vrental.find(params[:vrental_id])
        redirect_to vrental_expenses_path(@vrental), notice: "La despesa per #{@vrental.name} s'ha creat correctament."
      else
        redirect_to expenses_path, notice: "La despesa s'ha creat correctament."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @expense
    @vrental = @expense.vrental

    if @expense.update(expense_params)
      redirect_to vrental_expenses_path(@vrental), notice: "La despesa per #{@vrental.name} s'ha modificat correctament."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @expense
    if params[:vrental_id].present?
      @vrental = Vrental.find(params[:vrental_id])
      @expense.destroy
      redirect_to vrental_expenses_path(@vrental), notice: "La despesa s'ha esborrat correctament."
    else
      @expense.destroy
      redirect_to expenses_path, notice: "La despesa s'ha esborrat correctament."
    end
  end

  private

  def set_expense
    @expense = Expense.find(params[:id])
  end

  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
  end

  def expense_params
    params.require(:expense).permit(:description, :amount, :expense_type, :expense_number, :expense_company, :vrental_id, :statement_id)
  end
end
