class RatesController < ApplicationController
  before_action :set_rate, only: [:show, :edit, :update, :destroy]
  before_action :set_vrental, only: [ :new, :create, :edit, :update, :index, :show ]

  # Index for rates is not really necessary
  def index
    @rates = policy_scope(Rate)
    @rates = Rate.where(vrental_id: @vrental).order(firstnight: :desc)
    @rates_dates = @rates.pluck(:firstnight)
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
      flash.now[:notice] = "Has creat una tarifa nova per #{@rate.vrental.name}."
      render turbo_stream: [
        turbo_stream.prepend("rates#{@rate.firstnight.year}", @rate),
        turbo_stream.replace("new_rate", partial: "form", locals: { rate: Rate.new }),
        turbo_stream.replace("notice", partial: "shared/flashes")
      ]
      # redirect_to vrental_path(@rate.vrental), notice: 'Has creat una tarifa nova.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @rate.vrental = @vrental
    authorize @rate
    if @rate.update(rate_params)
      # redirect_to vrental_path(@rate.vrental), notice: 'Has actualitzat la tarifa.'
      flash.now[:notice] = "Has actualitzat la tarifa de #{@rate.vrental.name}."
      render turbo_stream: [
        turbo_stream.replace(@rate, @rate),
        turbo_stream.replace("notice", partial: "shared/flashes")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    authorize @rate
    @rate.destroy
    flash.now[:notice] = "Has esborrat una tarifa de #{@rate.vrental.name}."
    render turbo_stream: [
      turbo_stream.remove(@rate),
      turbo_stream.replace("notice", partial: "shared/flashes")
    ]
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
