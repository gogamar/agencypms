class OwnerPaymentsController < ApplicationController
  before_action :set_owner_payment, except: [:create]
  before_action :set_statement

  def create
    @owner_payment = OwnerPayment.new(owner_payment_params)
    authorize @owner_payment
    authorize @statement
    @owner_payment.statement = @statement

    if @owner_payment.save
      redirect_to vrental_statements_path(@statement.vrental), notice: 'Has marcat la liquidació com pagada.'
    else
      puts "these are owner payment errors: #{@owner_payment.errors.full_messages}"
      flash[:alert] = 'No s\'ha pogut marcar la liquidació com pagada.'
    end
  end

  def update
    authorize @owner_payment

    if @owner_payment.update(owner_payment_params)
      redirect_to vrental_statements_path(@statement.vrental), notice: 'Has actualitzat el pagament.'
    else
      flash[:alert] = 'No s\'ha pogut actualitzar el pagament.'
    end
  end

  def destroy
    authorize @owner_payment

    if @owner_payment.statement.invoice && Date.current > @owner_payment.statement.invoice.created_at.to_date
      redirect_to vrental_statements_path(@owner_payment.statement.vrental), alert: 'No pots esborrar aquest pagament perquè ja ha passat més d\'un dia des de la creació de la factura.'
    else
      @owner_payment.destroy
      redirect_to vrental_statements_path(@owner_payment.statement.vrental), notice: 'Has esborrat el pagament.'
    end
  end

  private

  def set_owner_payment
    @owner_payment = OwnerPayment.find(params[:id])
  end

  def set_statement
    @statement = Statement.find(params[:statement_id])
  end

  def owner_payment_params
    params.require(:owner_payment).permit(:description, :amount, :date, :statement_id)
  end
end
