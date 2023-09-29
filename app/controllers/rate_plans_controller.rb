class RatePlansController < ApplicationController
  before_action :set_rate_plan, only: %i[ show edit update destroy upload_rate_dates delete_periods ]

  def index
    @rate_plans = policy_scope(RatePlan)
  end

  def show
    @rate_periods = @rate_plan.rate_periods
    @year = @rate_plan.start.year
    @vrentals_with_rates = Vrental.joins(:rates)
                                  .where("EXTRACT(YEAR FROM rates.firstnight) = ?", @year)
                                  .distinct
  end

  def new
    @rate_plan = RatePlan.new
    authorize @rate_plan
    @rate_plan.start = Date.today.month < 9 ? Vrental::EASTER_SEASON_FIRSTNIGHT[Date.today.year] : Vrental::EASTER_SEASON_FIRSTNIGHT[Date.today.year + 1]
    @rate_plan.end = Date.today.month < 9 ? Date.new(Date.today.year, 10, 1) : Date.new(Date.today.year + 1, 10, 1)
  end

  def upload_rate_dates
    @vrental = Vrental.find(params[:vrental_id])
    result = @vrental.upload_dates_to_plan(@rate_plan.start.year, @rate_plan)
    case result
    when :no_rates_found
      redirect_back(fallback_location: rate_plan_rate_periods_path(@rate_plan), notice: "L'immoble #{@vrental.name} no té tarifes per #{@rate_plan.start.year}.")
    when :success
      redirect_back(fallback_location: rate_plan_rate_periods_path(@rate_plan), notice: "Ja s'han importat les dates de tarifes.")
    end
  end

  def edit
  end

  def create
    @rate_plan = RatePlan.new(rate_plan_params)
    authorize @rate_plan

    if @rate_plan.save
      redirect_to @rate_plan, notice: "Pla de tarifes creat."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @rate_plan.update(rate_plan_params)
      redirect_to @rate_plan, notice: "Pla de tarifes actualitzat."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rate_plan.destroy
    redirect_to rate_plans_url, notice: "Pla de tarifes esborrat."
  end

  def delete_periods
    @rate_plan.rate_periods.destroy_all
    redirect_to @rate_plan, notice: "S'han esborrat tots els periodes."
  end

  private
    def set_rate_plan
      @rate_plan = RatePlan.find(params[:id])
      authorize @rate_plan
    end

    def rate_plan_params
      params.require(:rate_plan).permit(:name, :start, :end, :gen_arrival, :gen_min, :company_id)
    end
end
