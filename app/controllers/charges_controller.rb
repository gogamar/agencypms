class ChargesController < ApplicationController
  before_action :set_charge, only: %i[ show edit update destroy ]

  # GET /charges or /charges.json
  def index
    @charges = Charge.all
  end

  # GET /charges/1 or /charges/1.json
  def show
  end

  # GET /charges/new
  def new
    @charge = Charge.new
  end

  # GET /charges/1/edit
  def edit
  end

  def create
    @charge = Charge.new(charge_params)

    respond_to do |format|
      if @charge.save
        redirect_to charge_url(@charge), notice: "Charge was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def update
    respond_to do |format|
      if @charge.update(charge_params)
        redirect_to charge_url(@charge), notice: "Charge was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @charge.destroy

    respond_to do |format|
      redirect_to charges_url, notice: "Charge was successfully destroyed."
    end
  end

  private
    def set_charge
      @charge = Charge.find(params[:id])
    end

    def charge_params
      params.require(:charge).permit(:description, :quantity, :price, :booking_id, :charge_type)
    end
end
