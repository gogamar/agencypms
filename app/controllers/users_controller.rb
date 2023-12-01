class UsersController < ApplicationController
  before_action :set_user, only: [:update, :destroy]

  def purge_photo
    current_user.photo.purge
    redirect_back fallback_location: root_path, notice: "Has esborrat la foto."
  end

  def index
    @users = policy_scope(User).where.not(id: current_user.id)
  end

  def update
    if @user.update(user_params)
      redirect_back fallback_location: users_path, notice: 'Has actualitzat l\'usuari.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_back fallback_location: users_path, notice: 'Has esborrat l\'usuari.'
  end

  private

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def user_params
    params.require(:user).permit(:approved, :company_id, :office_id)
  end
end
