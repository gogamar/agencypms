class RatePeriodsController < ApplicationController
  before_action :set_rate_period, only: %i[ show edit update destroy ]
  before_action :set_rate_plan, only: %i[ index new edit update create destroy ]

  def index
    @rate_periods = policy_scope(RatePeriod).order(:firstnight)
  end

  def show
  end

  def new
    @rate_period = RatePeriod.new
    authorize @rate_period
    @rate_period.firstnight = @rate_plan.start if !@rate_plan.rate_periods.any?
    @rate_period.arrival_day = @rate_plan.gen_arrival
    @rate_period.min_stay = @rate_plan.gen_min
  end

  def edit
  end

  def create
    @rate_period = RatePeriod.new(rate_period_params)
    authorize @rate_period
    @rate_period.rate_plan = @rate_plan

    if @rate_period.save
      redirect_to rate_plan_rate_periods_path(@rate_plan), notice: "Peride de tarifes creat."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @rate_period.update(rate_period_params)
      redirect_to rate_plan_rate_periods_path(@rate_plan), notice: "Periode de tarifa actualitzat."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rate_period.destroy

    redirect_to rate_plan_rate_periods_path(@rate_plan), notice: "Periode de tarifa esborrat."
  end

  private
    def set_rate_period
      @rate_period = RatePeriod.find(params[:id])
      authorize @rate_period
    end

    def set_rate_plan
      @rate_plan = RatePlan.find(params[:rate_plan_id])
      authorize @rate_plan
    end

    def rate_period_params
      params.require(:rate_period).permit(:name, :firstnight, :lastnight, :min_stay, :arrival_day, :rate_plan_id)
    end
end
