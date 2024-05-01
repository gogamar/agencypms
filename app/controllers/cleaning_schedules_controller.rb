class CleaningSchedulesController < ApplicationController

  def index
    @cleaning_schedules = CleaningSchedule.all
  end

  def show
    @cleaning_schedule = CleaningSchedule.find(params[:id])
  end

  def edit
    @cleaning_schedule = CleaningSchedule.find(params[:id])
    @offices = Office.all
    @cleaning_companies = CleaningCompany.all
  end

  def new
    @cleaning_schedule = CleaningSchedule.new
    @offices = Office.all
    @cleaning_companies = CleaningCompany.all
  end

  def create
    @cleaning_schedule = CleaningSchedule.new(cleaning_schedule_params)
    if @cleaning_schedule.save
      redirect_to @cleaning_schedule, notice: 'Cleaning schedule was successfully created.'
    else
      @offices = Office.all
      @cleaning_companies = CleaningCompany.all
      render :new
    end
  end

  private

  def cleaning_schedule_params
    # Adjust parameters based on your form fields
    params.require(:cleaning_schedule).permit(:from_date, :to_date, :office_id, cleaning_companies: {})
  end
end
