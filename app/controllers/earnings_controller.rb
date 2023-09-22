class EarningsController < ApplicationController
  before_action :set_earning, only: [:show, :edit, :update, :destroy, :unlock ]
  before_action :set_vrental, only: [ :new, :create, :edit, :update, :show, :unlock ]

  def index
    all_earnings = policy_scope(Earning)
    @pagy, @earnings = pagy(all_earnings, page: params[:page], items: 10)
    @vrental = Vrental.find(params[:vrental_id]) if params[:vrental_id]
    @earnings = @vrental ? @vrental.earnings.order(date: :asc) : @earnings.order(date: :asc)
    @bookings = @vrental.bookings.where(checkin: @earnings.first.date..@earnings.last.date) if @vrental && @earnings.any?
  end

  def list
    @earnings = policy_scope(Earning).includes(:vrental)
    @earnings = @earnings.joins(:vrental).where("unaccent(vrentals.name) ILIKE ?", "%#{params[:vrental_name]}%") if params[:vrental_name].present?

    @earnings = @earnings.order("#{params[:column]} #{params[:direction]}")
    @pagy, @earnings = pagy(@earnings, page: params[:page], items: 10)
    # render(partial: 'earnings', locals: { earnings: @earnings })
  end

  def new
    @earning = Earning.new
    authorize @earning
  end

  def show
    authorize @earning
  end

  def edit
    authorize @earning
  end

  def unlock
    authorize @earning
    @earning.update(locked: false)
    @earning.booking.update(locked: false) if @earning.booking.present?
    redirect_to vrental_earnings_path(@vrental), notice: 'Ingres desprotegit i serà modificat al importar reserves de nou.'
  end

  def create
    @earning = Earning.new(earning_params)
    @earning.vrental = @vrental
    authorize @earning
    if @earning.save
      redirect_to vrental_earnings_path(@vrental), notice: "Has creat un ingres nou per #{@earning.vrental.name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @vrental = @earning.vrental
    authorize @earning
    if @earning.update(earning_params)
      @earning.locked = true
      @earning.save
      redirect_back(fallback_location: @earning.statement)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @earning
    @vrental = @earning.vrental
    @earning.destroy
    redirect_to vrental_earnings_path(@vrental), notice: "Has esborrat l'ingres #{@earning.description}."
  end

  private

  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
  end

  def set_earning
    @earning = Earning.find(params[:id])
  end

  def earning_params
    params.require(:earning).permit(:vrental_id, :statement_id, :date, :amount, :description, :discount)
  end
end
