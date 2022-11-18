class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy, :purge_photo]
  skip_before_action :authenticate_profile!

  def purge_photo
    @profile = Profile.find(params[:id])
    @profile.photo.purge
    redirect_back fallback_location: root_path, notice: "Has esborrat la foto."
  end

  def show
    authorize @profile
  end

  def new
    @comtypes = Comtype.all
    @profile = Profile.new
    authorize @profile
  end

  def destroy
    authorize @profile
    @profile.destroy
    redirect_to new_profile_session_path, notice: 'Has esborrat el perfil.'
  end

  def create
    @profile = Profile.new(profile_params)
    @profile.user = current_user
    authorize @profile
    if @profile.save
      profile_log_in @profile
      flash[:success] = "Has creat un nou perfil!"
      redirect_to new_profile_session_path
    else
      render :new
    end
  end

  def edit
    authorize @profile
    @comtypes = policy_scope(Comtype)
  end

  def update
    authorize @profile
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
    params.require(:profile).permit(:businessname, :officeaddress, :officezip, :officecity, :officephone, :companyname, :address, :companyzip, :companycity, :companyphone, :vat, :photo, :comtype_id, :user_id)
  end
end
