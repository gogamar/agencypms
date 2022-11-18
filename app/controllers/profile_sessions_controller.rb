class ProfileSessionsController < ApplicationController
  skip_before_action :authenticate_profile!
  before_action :skip_authorization

  def new
    @profiles = current_user.profiles
    redirect_to new_profile_path if current_user.profiles.empty?
  end

  def create
    profile = Profile.find_by(id: params[:profile_id])
    if profile
      session[:profile_id] = profile.id
        if profile.comtype_id == 1
          redirect_to agreements_path
        elsif profile.comtype_id == 2
          redirect_to vragreements_path
        else
          redirect_to root_path
        end
    else
      redirect_to new_profile_session_path
    end
  end

  def destroy
    profile_log_out
    redirect_to root_url
  end

end
