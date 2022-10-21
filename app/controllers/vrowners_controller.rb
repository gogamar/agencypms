class VrownersController < ApplicationController
  before_action :set_vrowner, only: [:show, :edit, :update]

  def show
  end

  def index
    @vrowners = policy_scope(Vrowner).order(:fullname)
  end

  def new
    @vrowner = Vrowner.new
  end

  def create
    @vrowner = Vrowner.new(vrowner_params)

    if @vrowner.save
      redirect_to vrowners_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @vrowner = Vrowner.find(params[:id])
  end

  def update
    @vrowner = Vrowner.find(params[:id])

    if @vrowner.update(vrowner_params)
      redirect_to vrowners_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Vrowner.destroy(params[:id])
    redirect_to vrowners_path
  end

  private

  def set_vrowner
    @vrowner = Vrowner.find(params[:id])
  end

  def vrowner_params
    params.require(:vrowner).permit(:fullname, :address, :phone, :email, :document, :account, :language, :beds_room_id)
  end
end
