class RatesController < ApplicationController
  # before_action :set_owner, only: [:show]
  before_action :set_rate, only: [:show, :edit, :update]
  #  before_action :set_vrental, only: [:show, :edit, :update]

  # GET /rates
  def index
    @rates = Rate.order(:firstnight)
    # @rates = rate.where(owner_id: @owner)
  end

  # GET /rates/1
  def show
    # @rate = Rate.find(params[:id])
    @vrental = @rate.vrental
  end

  # GET /rates/new
  def new
    @vrental = Vrental.find_by(id: params[:vrental_id])
    @rate = Rate.new
  end

x # GET /rates/1/edit
  def edit
  end

  def create
    @rate = Rate.new(rate_params)
    @vrental = Vrental.find(params[:vrental_id])
    @rate.vrental = @vrental
    if @rate.save
      redirect_to vrental_path(@rate.vrental), notice: 'Has creat una tarifa nova.'
    else
      render :new
    end
  end


  # PATCH/PUT /rates/1
  def update
    @vrental = Vrental.find(params[:vrental_id])
    @rate.vrental = @vrental
    if @rate.update(rate_params)
      redirect_to @rate, notice: 'rate was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /rates/1
  def destroy
    @rate.destroy
    redirect_to rates_url, notice: 'rate was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_owner
      # @reviews = Review.where(restaurant_id: @restaurant)
    end

    def set_rate
      @rate = Rate.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def rate_params
      params.require(:rate).permit(:pricenight, :beds_room_id, :firstnight, :lastnight, :min_stay, :arrival_day, :priceweek, :vrental_id)
    end
end
