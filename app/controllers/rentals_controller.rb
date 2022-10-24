class RentalsController < ApplicationController
  before_action :set_rental, only: [:show, :edit, :update, :destroy]

  def index
    @rentals = policy_scope(Rental)
    @rentals = Rental.all.sort_by(&:created_at).reverse
  end

  def show
    authorize @rental
    @owner = @rental.owner
  end

  def new
    @rental = Rental.new
    authorize @rental
  end

  def edit
    authorize @rental
  end

  def create
    @rental = Rental.new(rental_params)
    @rental.user_id = current_user.id
    authorize @rental
    if @rental.save
      redirect_to rentals_path, notice: 'Has creat un nou immoble.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @rental
    if @rental.update(rental_params)
      redirect_to rentals_path, notice: 'Has actualitzat l\'immoble.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @rental
    @rental.destroy
    redirect_to rentals_url, notice: 'S\'ha esborrat l\'immoble.'
  end

  private

  def set_rental
    @rental = Rental.find(params[:id])
  end

  def rental_params
    params.require(:rental).permit(:address, :cadastre, :energy, :owner_id, :description, :city)
  end
end
