class RentalsController < ApplicationController
  before_action :set_rental, only: [:show, :edit, :update, :destroy]

  def index
    all_rentals = policy_scope(Rental)
    @pagy, @rentals = pagy(all_rentals, page: params[:page], items: 10)
    # .sort_by(&:created_at).reverse
  end

  def list
    @rentals = policy_scope(Rental).includes(:owner)
    @rentals = @rentals.where('address ilike ?', "%#{params[:address]}%") if params[:address].present?
    @rentals = @rentals.where(status: params[:status]) if params[:status].present?
    @rentals = @rentals.order("#{params[:column]} #{params[:direction]}")
    @pagy, @rentals = pagy(@rentals, page: params[:page], items: 10)
    render(partial: 'rentals', locals: { rentals: @rentals })
  end

  def show
    authorize @rental
    @owner = @rental.owner
  end

  def new
    @rental = Rental.new
    authorize @rental
  end

  def copy
    @source = Rental.find(params[:id])
    @rental = @source.dup
    @rental.address = "#{@rental.address} CÒPIA"
    authorize @rental
    @rental.save!
    redirect_to rentals_path, notice: "S'ha creat una còpia de l'immoble: #{@rental.address}."
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
    params.require(:rental).permit(:address, :cadastre, :energy, :owner_id, :description, :city, :status)
  end
end
