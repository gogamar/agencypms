class CleaningSchedulesController < ApplicationController
  before_action :set_cleaning_schedule, only: [:edit, :update, :destroy, :unlock]
  before_action :set_office, only: [:index, :new, :edit, :create, :destroy, :update, :update_all, :unlock, :load_pdf_modal]

  def index
    from_date = params[:from_cleaning_date].present? ? Date.parse(params[:from_cleaning_date]) : Date.today
    to_date = params[:to_cleaning_date].present? ? Date.parse(params[:to_cleaning_date]) : Date.today + 14.days
    @incomplete_cleaning_schedules = @office.cleaning_schedules.where(full: false).where('cleaning_date < ?', Date.today).order(:cleaning_date)

    find_bookings_without_cleaning

    load_cleaning_schedules(@office, from_date, to_date)
    filter_cleaning_schedules
    @grouped_cleaning_schedules = @cleaning_schedules.group_by(&:cleaning_date)
    @header_title = set_header_title

    respond_to do |format|
      format.html
      format.pdf do
        render_pdf
      end
    end
  end

  def load_pdf_modal
    render partial: 'pdf_modal', locals: { cleaning_schedules: @grouped_cleaning_schedules, cleaning_company_id: params[:cleaning_company_id], from_cleaning_date: params[:from_cleaning_date], to_cleaning_date: params[:to_cleaning_date] }
  end

  def new
    @cleaning_schedule = CleaningSchedule.new
    authorize @cleaning_schedule
    @cleaning_companies = CleaningCompany.all
  end

  def create
    @cleaning_schedule = CleaningSchedule.new(cleaning_schedule_params)
    authorize @cleaning_schedule
    @cleaning_schedule.office = @office
    if @cleaning_schedule.save
      render(partial: 'cleaning_schedule', locals: { cleaning_schedule: @cleaning_schedule})
    else
        @cleaning_companies = CleaningCompany.all
      render :new
    end
  end

  def edit
    @cleaning_companies = CleaningCompany.all
  end

  def update
    if @cleaning_schedule.update(cleaning_schedule_params)
      cleaning_company = @cleaning_schedule.cleaning_company
      cleaning_company.update_priority(@cleaning_schedule.cleaning_date)
      @cleaning_schedule.update(locked: true)
      redirect_back(fallback_location: office_cleaning_schedules_path(@office), notice: "Horari de neteja actualitzat.")
    else
      puts "ERRORS cleaning schedule update: #{@cleaning_schedule.errors}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cleaning_schedule.destroy
    redirect_to office_cleaning_schedules_path(@office), notice: "Has esborrat el planning de neteja."
  end

  def update_all
    authorize @office
    puts "update all cleaning schedules: #{params}"
    puts "update all cleaning schedules the office is: #{@office.name}"
    from = Date.today
    to = params[:to].to_date
    CleaningSchedulesService.new(@office, from, to).update_cleaning_schedules
    redirect_to office_cleaning_schedules_path(@office), notice: "S'han creat o actualitzat els horaris de neteja."
  end

  def unlock
    @cleaning_schedule.update(locked: false)
    redirect_to office_cleaning_schedules_path(@office), notice: "Horari de neteja desprotegit i serà modificat al actualitzar els horaris de neteja."
  end

  private

  def find_bookings_without_cleaning
    if @office.cleaning_schedules.present?
      office_cleaning_dates = @office.cleaning_schedules.pluck(:cleaning_date)
      first_cleaning_date = office_cleaning_dates.min
      @last_cleaning_date = office_cleaning_dates.max

      if first_cleaning_date && @last_cleaning_date
        @bookings_without_cleaning = @office.bookings
                                            .where(checkout: first_cleaning_date..@last_cleaning_date)
                                            .where.not(id: @office.cleaning_schedules.pluck(:booking_id))
                                            .order(:checkout)
      else
        @bookings_without_cleaning = []
      end
    else
      @bookings_without_cleaning = []
    end
  end

  def load_cleaning_schedules(office, from_date, to_date)
    @cleaning_schedules = office.cleaning_schedules
                                 .where("cleaning_date BETWEEN ? AND ?", from_date, to_date)
                                 .order(:cleaning_date)
  end

  def filter_cleaning_schedules
    if params[:cleaning_company_id].present?
      @cleaning_schedules = @cleaning_schedules.where(cleaning_company_id: params[:cleaning_company_id])
      @selected_cleaning_company = CleaningCompany.find(params[:cleaning_company_id])
    end

    if params[:from_cleaning_date].present?
      @cleaning_schedules = @cleaning_schedules.where('cleaning_date >= ?', params[:from_cleaning_date])
    end

    if params[:to_cleaning_date].present?
      @cleaning_schedules = @cleaning_schedules.where('cleaning_date <= ?', params[:to_cleaning_date])
    end
  end

  def set_header_title
    title_array = [t('cleaning_schedules')]
    if @selected_cleaning_company.present?
      title_array << @selected_cleaning_company.name
    end
    if params[:from_cleaning_date].present?
      from = Date.parse(params[:from_cleaning_date])
      title_array << "#{t('from_min')} #{l(from, format: :long)}"
    end
    if params[:to_cleaning_date].present?
      to = Date.parse(params[:to_cleaning_date])
      title_array << "#{t('to_min')} #{l(to, format: :long)}"
    end
    title_array.join(' ')
  end

  def render_pdf
    render pdf: @header_title,
           template: "cleaning_schedules/index",
           locals: { cleaning_schedules: @grouped_cleaning_schedules, header_title: @header_title },
           margin: { top: 50, bottom: 25, left: 10, right: 10 },
           header: {
            font_size: 9,
            spacing: 10,
            content: render_to_string(
              'shared/pdf_header_cleaning',
              locals: { header_title: @header_title}
            )
           },
           formats: [:html],
           disposition: :inline,
           page_size: 'A4',
           dpi: 75,
           zoom: 1,
           layout: 'pdf',
           footer: {
             font_size: 9,
             spacing: 5,
             right: "#{t('page')} [page] #{t('of')} [topage]",
             left: t('printed_on', date: l(Date.current, format: :long))
           }
  end

  def set_office
    @office = Office.find(params[:office_id])
  end

  def set_cleaning_schedule
    @cleaning_schedule = CleaningSchedule.find(params[:id])
    authorize @cleaning_schedule
  end

  def cleaning_schedule_params
    params.require(:cleaning_schedule).permit(:cleaning_start, :cleaning_end, :booking_id, :cleaning_date, :next_booking_info, :priority, :next_booking_date, :locked, :notes, :next_client_name, :full, :office_id, :cleaning_company_id)
  end
end
