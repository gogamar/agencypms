class OwnersController < ApplicationController
  before_action :set_owner, only: [:show, :edit, :update, :destroy]
  def index
    @owners = policy_scope(Owner)
    @owners = Owner.order(:fullname)
  end

  def show
    authorize @owner
  end

  def new
    @owner = Owner.new
    authorize @owner
  end

  def create
    @owner = Owner.new(owner_params)
    @owner.user_id = current_user.id
    authorize @owner
    if @owner.save
      redirect_to owners_path, notice: "Has creat un nou propietari"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @owner
  end

  def update
    authorize @owner
    if @owner.update(owner_params)
      redirect_to owners_path, notice: "Has actualitzat al propietari"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @owner
    @owner.destroy
    redirect_to owners_path, notice: "Has esborrat al propietari"
  end

  private

  def set_owner
    @owner = Owner.find(params[:id])
  end

  def owner_params
    params.require(:owner).permit(:fullname, :address, :document, :account, :language)
  end
end
