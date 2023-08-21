class TouristsController < ApplicationController
  before_action :set_tourist, only: %i[ show edit update destroy ]

  # GET /tourists or /tourists.json
  def index
    @tourists = Tourist.all
  end

  # GET /tourists/1 or /tourists/1.json
  def show
  end

  # GET /tourists/new
  def new
    @tourist = Tourist.new
  end

  # GET /tourists/1/edit
  def edit
  end

  # POST /tourists or /tourists.json
  def create
    @tourist = Tourist.new(tourist_params)

    respond_to do |format|
      if @tourist.save
        format.html { redirect_to tourist_url(@tourist), notice: "Tourist was successfully created." }
        format.json { render :show, status: :created, location: @tourist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tourist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tourists/1 or /tourists/1.json
  def update
    respond_to do |format|
      if @tourist.update(tourist_params)
        format.html { redirect_to tourist_url(@tourist), notice: "Tourist was successfully updated." }
        format.json { render :show, status: :ok, location: @tourist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tourist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tourists/1 or /tourists/1.json
  def destroy
    @tourist.destroy

    respond_to do |format|
      format.html { redirect_to tourists_url, notice: "Tourist was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tourist
      @tourist = Tourist.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def tourist_params
      params.require(:tourist).permit(:firstname, :lastname, :phone, :email, :address, :country_code, :country, :document)
    end
end
