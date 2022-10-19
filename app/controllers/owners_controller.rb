class OwnersController < ApplicationController
  def index
    @owners = Owner.order(:fullname)
  end

  def new
    @owner = Owner.new
  end

  def create
    @owner = Owner.new(owner_params)

    if @owner.save
      redirect_to new_owner_agreement_path(@owner)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @owner = Owner.find(params[:id])
  end

  def update
    @owner = Owner.find(params[:id])

    if @owner.update(owner_params)
      redirect_to owners_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Owner.destroy(params[:id])
    redirect_to owners_path
  end

  private

  def owner_params
    params.require(:owner).permit(:fullname, :address, :document, :account, :language)
  end
end
