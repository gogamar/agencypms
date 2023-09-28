class RatePlansController < ApplicationController
  before_action :set_rate_plan, only: %i[ show edit update destroy ]

  def index
    @rate_plans = policy_scope(RatePlan)
  end

  def show
    @rate_periods = @rate_plan.rate_periods
  end

  def new
    @rate_plan = RatePlan.new
    authorize @rate_plan
    @rate_plan.start = Date.today.month < 9 ? Vrental::EASTER_SEASON_FIRSTNIGHT[Date.today.year] : Vrental::EASTER_SEASON_FIRSTNIGHT[Date.today.year + 1]
    @rate_plan.end = Date.today.month < 9 ? Date.new(Date.today.year, 10, 1) : Date.new(Date.today.year + 1, 10, 1)
  end

  def edit
  end

  def create
    @rate_plan = RatePlan.new(rate_plan_params)
    authorize @rate_plan

    if @rate_plan.save
      redirect_to rate_plan_rate_periods_path(@rate_plan), notice: "Pla de tarifes creat."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @rate_plan.update(rate_plan_params)
      redirect_to rate_plan_rate_periods_path(@rate_plan), notice: "Pla de tarifes actualitzat."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rate_plan.destroy
    redirect_to rate_plans_url, notice: "Pla de tarifes esborrat."
  end

  private
    def set_rate_plan
      @rate_plan = RatePlan.find(params[:id])
      authorize @rate_plan
    end

    def rate_plan_params
      params.require(:rate_plan).permit(:start, :end, :gen_arrival, :gen_min, :company_id)
    end
end
