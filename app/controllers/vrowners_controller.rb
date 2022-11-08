class VrownersController < ApplicationController
  before_action :set_vrowner, only: [:show, :edit, :update, :destroy]

  def index
    all_vrowners = policy_scope(Vrowner).order(:fullname)
    @pagy, @vrowners = pagy(all_vrowners, page: params[:page], items: 9)
  end

  def filter
    @vrowners = policy_scope(Vrowner)
    @languages = Vrowner.pluck("language").uniq
    @vrowners = @vrowners.where('fullname ilike ?', "%#{params[:fullname]}%") if params[:fullname].present?
    @vrowners = @vrowners.where(language: params[:language]) if params[:language].present?
    @pagy, @vrowners = pagy(@vrowners, page: params[:page], items: 9)
    render(partial: 'vrowners', locals: { vrowners: @vrowners })
  end

  def show
    authorize @vrowner
  end

  def new
    @vrowner = Vrowner.new
    authorize @vrowner
  end

  def create
    @vrowner = Vrowner.new(vrowner_params)
    @vrowner.user_id = current_user.id
    authorize @vrowner
    if @vrowner.save
      redirect_to vrowners_path, notice: 'Has creat un nou propietari de lloguer turístic.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @vrowner
  end

  def update
    authorize @vrowner
    if @vrowner.update(vrowner_params)
      redirect_to vrowners_path, notice: "Has actualitzat al propietari"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @vrowner
    @vrowner.destroy
    redirect_to vrowners_path, notice: "Has esborrat al propietari"
  end

  private

  def set_vrowner
    @vrowner = Vrowner.find(params[:id])
  end

  def vrowner_params
    params.require(:vrowner).permit(:fullname, :address, :phone, :email, :document, :account, :language, :beds_room_id)
  end
end
