class RatesController < ApplicationController
  before_action :set_rate, only: [:show, :edit, :update, :destroy]
  before_action :set_vrental, only: [ :new, :create, :edit, :update, :index, :show]


  def index
    @rates = policy_scope(Rate)
    if @vrental.price_per == "night"
      @rates = @vrental.rates.where.not(pricenight: nil).order(firstnight: :asc)
    elsif @vrental.price_per == "week"
      @rates = @vrental.rates.where.not(priceweek: nil).or(@vrental.rates.where(restriction: "gap_fill")).order(firstnight: :asc)
    end
    @rate = Rate.new
    @rates_sent_to_beds = @rates.where.not(sent_to_beds: nil)
    @modified_rates = @rates_sent_to_beds.where("updated_at > date_sent_to_beds")
    @rate_plans = RatePlan.where(company_id: @vrental.vrental_company.id) if @vrental.vrental_company.present?
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
      if @rate.vrental.price_per == "week" && @rate.priceweek.present?
        @rate.create_nightly_rate
        # @vrental.add_availability(@rate.firstnight, @rate.lastnight)
      end
      render(partial: 'rate', locals: { rate: @rate })
    else
      puts "rate creation errors: #{rate.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @vrental = @rate.vrental
    authorize @rate
    if @rate.update(rate_params)
      if @rate.vrental.price_per == "week" && @rate.priceweek.present?
        @rate.update_nightly_rate
      end
      flash.now[:notice] = "Has actualitzat una tarifa de #{@rate.vrental.name}."
      redirect_to vrental_rates_path(@vrental)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @rate
    @vrental = @rate.vrental
    if @rate.vrental.price_per == "week"
      @rate.delete_nightly_rate
    end
    @rate.destroy
    redirect_to vrental_rates_path(@vrental), notice: "Has esborrat la tarifa de #{@rate.firstnight}."
  end

  private

  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
  end

  def set_rate
    @rate = Rate.find(params[:id])
  end

  def rate_params
    params.require(:rate).permit(:pricenight, :beds_room_id, :firstnight, :lastnight, :min_stay, :max_stay, :restriction, :arrival_day, :priceweek, :vrental_id, :sent_to_beds, :date_sent_to_beds, :nights, :beds_rate_id)
  end
end
