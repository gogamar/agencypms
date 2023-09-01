class EarningsController < ApplicationController
  before_action :set_earning, only: [:show, :edit, :update, :destroy, :unlock, :mark_as_paid]
  before_action :set_vrental, only: [ :new, :create, :edit, :update, :index, :show, :unlock, :mark_as_paid]

  def index
    @earnings = policy_scope(Earning)
    @vrental = Vrental.find(params[:vrental_id]) if params[:vrental_id]
    @earnings = @vrental.earnings.order(date: :asc)
    @total_earnings = @earnings.pluck(:amount)&.sum
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
    redirect_to vrental_earnings_path(@vrental), notice: 'Ingres desprotegit i serà modificat al importar reserves de nou.'
  end

  def mark_as_paid
    authorize @earning
    @earning.update(paid: true)
    redirect_to vrental_earnings_path(@vrental), notice: 'Ingres marcat com pagat i no serà modificat al importar reserves de nou.'
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
    request_context = params[:earning][:request_context]
    params[:earning][:discount] = params[:earning][:discount].to_f / 100.0
    discount = params[:earning][:discount]
    rate_price = @earning.vrental.rate_price(@earning.booking.checkin, @earning.booking.checkout)
    if @earning.update(earning_params)
      if request_context && request_context == 'update_discount'
        @earning.amount = rate_price - (rate_price * discount)
        @earning.locked = true
        @earning.save
      end
      flash.now[:notice] = "Has actualitzat un ingres de #{@earning.vrental.name}."
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
