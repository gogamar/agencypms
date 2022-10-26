class RatesController < ApplicationController
  before_action :set_rate, only: [:show, :edit, :update, :destroy]
  before_action :set_vrental, only: [ :new, :create, :edit, :update, :index ]

  # Index for rates is not really necessary
  def index
    @rates = policy_scope(Rate)
    @rates = Rate.where(vrental_id: @vrental)
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
    authorize @rate
    if @rate.save
      redirect_to vrental_path(@rate.vrental), notice: 'Has creat una tarifa nova.'
    else
      render :new
    end
  end

  def update
    @rate.vrental = @vrental
    authorize @rate
    if @rate.update(rate_params)
      # redirect_to vrental_path(@rate.vrental), notice: 'Has actualitzat la tarifa.'
      redirect_to vrental_rates_path(@vrental), notice: "Has actualitzat la tarifa - 2"
    else
      render :edit
    end
  end

  def destroy
    authorize @rate
    @rate.destroy
    redirect_to vrental_path(@rate.vrental), notice: 'Has esborrat la tarifa.'
  end

  private

  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
  end

  def set_rate
    @rate = Rate.find(params[:id])
  end

  def rate_params
    params.require(:rate).permit(:pricenight, :beds_room_id, :firstnight, :lastnight, :min_stay, :arrival_day, :priceweek, :vrental_id)
  end
end
