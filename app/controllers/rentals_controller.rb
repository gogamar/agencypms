class RentalsController < ApplicationController
  # before_action :set_owner, only: [:show]
  before_action :set_rental, only: [:show, :edit, :update]

  # GET /rentals
  def index
    @rentals = Rental.all
    # @rentals = rental.where(owner_id: @owner)
  end

  # GET /rentals/1
  def show
    # @rental = Rental.find(params[:id])
    @owner = @rental.owner
  end

  # GET /rentals/new
  def new
    # @owner = Owner.find(params[:owner_id])
    @rental = Rental.new
  end

  # GET /rentals/1/edit
  def edit
  end

  # POST /rentals
  def create
    @rental = Rental.new(rental_params)
    # @owner = Owner.find(params[:owner_id])
    # @rental.owner = @owner
    if @rental.save
      redirect_to rentals_path
    else
      render 'new'
    end
  end

  # PATCH/PUT /rentals/1
  def update
    if @rental.update(rental_params)
      redirect_to @rental, notice: 'rental was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /rentals/1
  def destroy
    @rental.destroy
    redirect_to rentals_url, notice: 'rental was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_owner
      # @reviews = Review.where(restaurant_id: @restaurant)
    end

    def set_rental
      @rental = Rental.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def rental_params
      params.require(:rental).permit(:address, :cadastre, :energy, :owner_id, :description, :city)
    end
end
