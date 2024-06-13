class CleaningSchedulesController < ApplicationController
  before_action :set_cleaning_schedule, only: [:edit, :update, :destroy, :unlock]

  def index
    load_cleaning_schedules
    if params[:cleaning_company_id].present?
      @cleaning_schedules = @cleaning_schedules.where(cleaning_company_id: params[:cleaning_company_id])
    end

    if params[:to_cleaning_date].present?
      @to_cleaning_date = Date.parse(params[:to_cleaning_date])
      @cleaning_schedules = @cleaning_schedules.where('cleaning_date <= ?', @to_cleaning_date)
    end
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
      render(partial: 'cleaning_schedule', locals: { cleaning_schedule: @cleaning_schedule})
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
      @cleaning_schedule.update_priority
      @cleaning_schedule.update(locked: true)
      redirect_to cleaning_schedules_path(@vrental)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cleaning_schedule.destroy
    redirect_to cleaning_schedules_path, notice: "Has esborrat el planning de neteja."
  end

  def create_or_update_schedules
    office = Office.find(params[:office_id])
    authorize office
    from = Date.today
    to = params[:to].to_date
    CleaningSchedulesService.new(office, from, to).update_cleaning_schedules
  end

  def unlock
    @cleaning_schedule.update(locked: false)
    redirect_to cleaning_schedules_path, notice: "Horari de neteja desprotegit i serà modificat al actualitzar els horaris de neteja."
  end

  private

  def load_cleaning_schedules
    @offices = Office.all.order(:name)
    @default_office = @offices.where("name ILIKE ?", '%estartit%').first
    @cleaning_schedules = policy_scope(CleaningSchedule)
                                   .where("cleaning_date >= ?", Date.today)
                                   .order(:cleaning_date)
  end

  def set_cleaning_schedule
    @cleaning_schedule = CleaningSchedule.find(params[:id])
    authorize @cleaning_schedule
  end

  def cleaning_schedule_params
    params.require(:cleaning_schedule).permit(:cleaning_start, :cleaning_end, :cleaning_company_id, :booking_id, :cleaning_date, :next_booking_info, :priority, :next_booking_date, :locked)
  end
end
