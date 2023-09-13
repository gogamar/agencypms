class VrownerPaymentsController < ApplicationController
  before_action :set_vrowner_payment, except: [:new, :create]
  before_action :set_statement

  def new
    @vrowner_payment = VrownerPayment.new
    authorize @vrowner_payment
  end

  def edit
    authorize @vrowner_payment
  end

  def create
    @vrowner_payment = VrownerPayment.new(vrowner_payment_params)
    authorize @vrowner_payment
    @vrowner_payment.statement = @statement
    @vrowner_payment.vrowner = @statement.vrental.vrowner

    if @vrowner_payment.save
      redirect_to vrental_statements_path(@vrowner_payment.statement.vrental), notice: 'Has marcat la liquidació com pagada.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @vrowner_payment

    if @vrowner_payment.update(vrowner_payment_params)
      redirect_to vrental_statements_path(@vrowner_payment.statement.vrental), notice: 'Has actualitzat el pagament.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @vrowner_payment

    if Date.current == @vrowner_payment.statement.invoice.created_at.to_date
      @vrowner_payment.destroy
      redirect_to vrental_statements_path(@vrowner_payment.statement.vrental), notice: 'Has esborrat el pagament.'
    else
      redirect_to vrental_statements_path(@vrowner_payment.statement.vrental), alert: 'No pots esborrar aquest pagament perquè ja ha passat més d\'un dia des de la creació de la factura.'
    end
  end

  private

  def set_vrowner_payment
    @vrowner_payment = VrownerPayment.find(params[:id])
  end

  def set_statement
    @statement = Statement.find(params[:statement_id])
  end

  def vrowner_payment_params
    params.require(:vrowner_payment).permit(:description, :amount, :date, :statement_id, :vrowner_id)
  end
end
