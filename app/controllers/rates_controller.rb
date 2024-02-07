class RatesController < ApplicationController
  before_action :set_rate, only: [:show, :edit, :update, :destroy, :update_rate_and_vrental_min_stay]
  before_action :set_vrental, only: [ :new, :create, :edit, :update, :index, :show, :update_rate_and_vrental_min_stay]

  def index
    @rates = policy_scope(Rate)
    @rates = @vrental.rates.order(firstnight: :asc)
    @rate = Rate.new
    @rate_plans = policy_scope(RatePlan)
  end

  def new
    @rate = Rate.new
    authorize @rate
  end

  def show
    authorize @rate
  end

  def edit
    authorize @rate
  end

  def create
    @rate = Rate.new(rate_params)
    @rate.vrental = @vrental
    @rate.beds_room_id = @vrental.beds_room_id
    @rate.max_stay = 365 if params[:rate][:max_stay].blank?
    authorize @rate
    if @rate.save
      update_rate_and_vrental_min_stay
      render(partial: 'rate', locals: { rate: @rate })
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @vrental = @rate.vrental
    authorize @rate
    if @rate.update(rate_params)
      update_rate_and_vrental_min_stay
      flash.now[:notice] = "Has actualitzat una tarifa de #{@rate.vrental.name}."
      redirect_to vrental_rates_path(@vrental)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @rate
    @vrental = @rate.vrental
    @rate.destroy
    redirect_to vrental_rates_path(@vrental), notice: "Has esborrat la tarifa de #{@rate.firstnight}."
  end

  private

  def set_vrental
    @vrental = Vrental.friendly.find(params[:vrental_id])
  end

  def set_rate
    @rate = Rate.find(params[:id])
  end

  def update_rate_and_vrental_min_stay
    if @rate.min_stay < 7
      @rate.update(arrival_day: 7)
    end
    rates_min_stay = @vrental.future_rates.where.not(min_stay: 0).minimum(:min_stay)
    @vrental.update(min_stay: rates_min_stay)
  end

  def rate_params
    params.require(:rate).permit(:pricenight, :beds_room_id, :firstnight, :lastnight, :min_stay, :max_stay, :restriction, :arrival_day, :priceweek, :vrental_id, :nights, :beds_rate_id)
  end
end
