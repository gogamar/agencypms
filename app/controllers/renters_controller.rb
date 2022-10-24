class RentersController < ApplicationController
  before_action :set_renter, only: [:show, :edit, :update, :destroy]

  def index
    @renters = policy_scope(Renter)
    @renters = Renter.all.sort_by(&:fullname)
  end


  def show
    authorize @renter
  end

  def new
    @renter = Renter.new
    authorize @renter
  end

  def edit
    authorize @renter
  end

  def create
    @renter = Renter.new(renter_params)
    @renter.user_id = current_user.id
    authorize @renter
    if @renter.save
      redirect_to renters_path, notice: "Has creat un inquili nou."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @renter
    if @renter.update(renter_params)
      redirect_to renters_path, notice: 'Has actualitzat l\'inquili.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @renter
    @renter.destroy
    redirect_to renters_url, notice: 'Has esborrat l\'inquiili.'
  end

  private

  def set_renter
    @renter = Renter.find(params[:id])
  end

  def renter_params
    params.require(:renter).permit(:fullname, :address, :document, :account, :language)
  end
end
