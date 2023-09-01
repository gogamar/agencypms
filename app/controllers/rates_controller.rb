class RatesController < ApplicationController

  before_action :set_rate, only: [:show, :edit, :update, :destroy]
  before_action :set_vrental, only: [ :new, :create, :edit, :update, :index, :show]

  def index
    @rates = policy_scope(Rate)
    @rates = Rate.where(vrental_id: @vrental).order(firstnight: :asc)
    @rate = Rate.new
    @rates_sent_to_beds = @rates.where.not(sent_to_beds: nil)
    @modified_rates = @rates_sent_to_beds.where("updated_at > date_sent_to_beds")
    @years = [Date.today.next_year.year, Date.today.year, Date.today.last_year.year]
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
      redirect_to vrental_path(@vrental) + "#tarifes", notice: "Has creat una tarifa nova per #{@rate.vrental.name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # def reset
  #   @rates = policy_scope(Rate)
  #   @rates = Rate.where(vrental_id: @vrental).order(firstnight: :desc)
  #   @rates
  #   redirect_to vrental_path(@vrental) + "#tarifes", notice: "Has esborrat totes les tarifes de #{@vrental.name}."
  # end

  def update
    @vrental = @rate.vrental
    authorize @rate
    if @rate.update(rate_params)
      flash.now[:notice] = "Has actualitzat una tarifa de #{@rate.vrental.name}."
      redirect_to @vrental
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    authorize @rate
    @vrental = @rate.vrental
    @rate.destroy
    redirect_to @vrental, notice: "Has esborrat la tarifa de #{@rate.firstnight}."
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
