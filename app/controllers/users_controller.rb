class UsersController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def purge_photo
    current_user.photo.purge
    redirect_back fallback_location: root_path, notice: "Has esborrat la foto."
  end

  def index
    if current_user.admin?
      @users = policy_scope(User).where.not(id: current_user.id)
    else
      redirect_back fallback_location: root_path, notice: "No estàs autoritzat a accedir a aquesta pàgina."
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    if @user.update(user_params)
      redirect_back fallback_location: users_path, notice: 'Has actualitzat l\'usuari.'
    else
      render :edit, status: :unprocessable_entity
    end
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:approved, :company_id)
  end

end
