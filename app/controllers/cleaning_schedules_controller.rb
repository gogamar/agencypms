class CleaningSchedulesController < ApplicationController
  before_action :set_cleaning_schedule, only: [:show, :edit, :update, :destroy]

  def index
    @cleaning_schedules = policy_scope(CleaningSchedule)
  end

  def show
  end

  def new
    @cleaning_schedule = CleaningSchedule.new
    authorize @cleaning_schedule
    @offices = Office.all
    @cleaning_companies = CleaningCompany.all
  end

  def create
    @cleaning_schedule = CleaningSchedule.new(cleaning_schedule_params)
    authorize @cleaning_schedule
    if @cleaning_schedule.save
      redirect_to @cleaning_schedule, notice: 'Cleaning plan was successfully created.'
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
    if @cleaning_schedule.update(cleaning_schedule_params)
      flash.now[:notice] = "Has actualitzat el planning de neteja #{@cleaning_schedule.name}."
      redirect_to dashboard_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cleaning_schedule.destroy
    redirect_to dashboard_path, notice: "Has esborrat el planning de neteja."
  end

  private

  def set_cleaning_schedule
    @cleaning_schedule = CleaningSchedule.find(params[:id])
    authorize @cleaning_schedule
  end

  def cleaning_schedule_params
    params.require(:cleaning_schedule).permit(:cleaning_start, :cleaning_end, :cleaning_company_id, :vrental_id)
  end
end
