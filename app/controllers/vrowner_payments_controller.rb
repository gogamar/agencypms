class VrownerPaymentsController < ApplicationController
  before_action :set_vrowner_payment, except: [:create]
  before_action :set_statement

  def create
    @vrowner_payment = VrownerPayment.new(vrowner_payment_params)
    authorize @vrowner_payment
    authorize @statement
    @vrowner_payment.statement = @statement

    if @vrowner_payment.save
      redirect_to vrental_statements_path(@statement.vrental), notice: 'Has marcat la liquidació com pagada.'
    else
      puts "these are vrowner payment errors: #{@vrowner_payment.errors.full_messages}"
      flash[:alert] = 'No s\'ha pogut marcar la liquidació com pagada.'
    end
  end

  def update
    authorize @vrowner_payment

    if @vrowner_payment.update(vrowner_payment_params)
      redirect_to vrental_statements_path(@statement.vrental), notice: 'Has actualitzat el pagament.'
    else
      flash[:alert] = 'No s\'ha pogut actualitzar el pagament.'
    end
  end

  def destroy
    authorize @vrowner_payment

    if @vrowner_payment.statement.invoice && Date.current > @vrowner_payment.statement.invoice.created_at.to_date
      redirect_to vrental_statements_path(@vrowner_payment.statement.vrental), alert: 'No pots esborrar aquest pagament perquè ja ha passat més d\'un dia des de la creació de la factura.'
    else
      @vrowner_payment.destroy
      redirect_to vrental_statements_path(@vrowner_payment.statement.vrental), notice: 'Has esborrat el pagament.'
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
    params.require(:vrowner_payment).permit(:description, :amount, :date, :statement_id)
  end
end
