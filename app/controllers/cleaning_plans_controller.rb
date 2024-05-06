class CleaningPlansController < ApplicationController
  before_action :set_cleaning_plan, only: [:show, :edit, :update, :destroy]

  def index
    @cleaning_plans = policy_scope(CleaningPlan)
  end

  def show
  end

  def new
    @cleaning_plan = CleaningPlan.new
    authorize @cleaning_plan
    @offices = Office.all
    @cleaning_companies = CleaningCompany.all
  end

  def create
    @cleaning_plan = CleaningPlan.new(cleaning_plan_params)
    authorize @cleaning_plan
    if @cleaning_plan.save
      @cleaning_plan.create_schedules_for_bookings
      redirect_to @cleaning_plan, notice: 'Cleaning plan was successfully created.'
    else
      @offices = Office.all
      @cleaning_companies = CleaningCompany.all
      render :new
    end
  end

  def edit
    @offices = Office.all
    @cleaning_companies = CleaningCompany.all
  end

  def update
    if @cleaning_plan.update(cleaning_plan_params)
      flash.now[:notice] = "Has actualitzat el planning de neteja #{@cleaning_plan.name}."
      redirect_to dashboard_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cleaning_plan.destroy
    redirect_to dashboard_path, notice: "Has esborrat el planning de neteja."
  end

  private

  def set_cleaning_plan
    @cleaning_plan = CleaningPlan.find(params[:id])
    authorize @cleaning_plan
  end

  def cleaning_plan_params
    params.require(:cleaning_plan).permit(:from, :to, :cleaning_company_id)
  end
end
