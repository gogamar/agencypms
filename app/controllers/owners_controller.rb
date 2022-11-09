class OwnersController < ApplicationController
  before_action :set_owner, only: [:show, :edit, :update, :destroy]

  def index
    all_owners = policy_scope(Owner)
    @pagy, @owners = pagy(all_owners, page: params[:page], items: 10)
  end

  def filter
    @owners = policy_scope(Owner)
    @languages = Owner.pluck("language").uniq
    @owners = @owners.where('fullname ilike ?', "%#{params[:fullname]}%") if params[:fullname].present?
    @owners = @owners.where(language: params[:language]) if params[:language].present?
    @pagy, @owners = pagy(@owners, page: params[:page], items: 10)
    render(partial: 'owners', locals: { owners: @owners })
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
      redirect_to owners_path, notice: "Has creat un nou propietari de lloguer anual."
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
    redirect_to owners_path, notice: "Has esborrat al propietari #{@owner.fullname}."
  end

  private

  def set_owner
    @owner = Owner.find(params[:id])
  end

  def owner_params
    params.require(:owner).permit(:fullname, :address, :phone, :email, :document, :account, :language)
  end
end
