class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]
  # before_action :skip_authorization, only: :index
  # # it was set to only show and edit, but it didn't allow modifying them then
  skip_before_action :authenticate_profile!

  def index
    @profiles = current_user.profiles
    # if params[:query].present?
    #   sql_query = " profiles.name ILIKE :query "
    #   @profiles = @profiles.where(sql_query, query: "%#{params[:query]}%")
    # end
  end

  def purge_photo
    current_profile.photo.purge
    redirect_back fallback_location: root_path, notice: "Has esborrat la foto."
  end

  def show
    @profile = Profile.find(params[:id])
    # authorize @profile
  end

  def new
    @profile = Profile.new
    # authorize @profile
  end

  def destroy
    @profile.destroy
    #redirect_to new_profile_session_path
    redirect_to profiles_url, notice: 'Profile was successfully destroyed.'
  end

  def create
    @profile = Profile.new(profile_params)
    # authorize @profile
    @profile.user = current_user
    if @profile.save
      profile_log_in @profile
      flash[:success] = "Has creat un nou perfil!"
      redirect_to new_profile_session_path
    else
      render :new
    end
  end

  def edit
    @profile = Profile.find(params[:id])
  end

  def update
    @profile = Profile.find(params[:id])
    if @profile.update(profile_params)
      redirect_to new_profile_session_path
    else
      render :new
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:businessname, :officeaddress, :officezip, :officecity, :officephone, :companyname, :address, :companyzip, :companycity, :companyphone, :vat, :companytype, :photo, :user_id)
  end
end
