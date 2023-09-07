class ExpensesController < ApplicationController
  before_action :set_vrental, except: %i[new create index destroy]
  before_action :set_expense, only: %i[edit update destroy]

  def index
    @expenses = policy_scope(Expense)
    @vrental = Vrental.find(params[:vrental_id]) if params[:vrental_id]
    @expenses = @vrental.present? ? @vrental.expenses.order(created_at: :asc) : @expenses.order(created_at: :asc)
    @total_expenses = @expenses.pluck(:amount)&.sum
    # @total_price = @vrental.expenses.pluck(:price)&.sum
    # @total_commission = @vrental.expenses.pluck(:commission)&.sum
    # @total_cleaning = @vrental.expenses.map do |expense|
    #   expense.charges.where(charge_type: 'cleaning').sum(:price)
    # end.sum
    # @total_city_tax = @vrental.expenses.map do |expense|
    #   expense.charges.where(charge_type: 'city_tax').sum(:price)
    # end.sum
    # @total_rent = @vrental.expenses.map do |expense|
    #   expense.charges.where(charge_type: 'rent').sum(:price)
    # end.sum
    # @total_net = @total_rent - @total_commission
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
    @vrental = params[:expense][:vrental_id].present? ? Vrental.find(params[:expense][:vrental_id]) : nil

    if @expense.save
      if request.referrer.include?(new_vrental_expense_path(@vrental))
        redirect_back(fallback_location: vrental_expenses_path(@vrental), notice: "La despesa per #{@vrental.name} s'ha creat correctament.")
      else
        redirect_to expenses_path, notice: "La despesa s'ha creat correctament."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @expense

    if @expense.update(expense_params)
      redirect_back(fallback_location: vrental_expenses_path(@vrental), notice: "La despesa per #{@vrental.name} s'ha modificat correctament.")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @expense
    @expense.destroy
    redirect_to vrental_expenses_path(@vrental), notice: "La despesa s'ha esborrat correctament."
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
