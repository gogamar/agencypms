class ProfileSessionsController < ApplicationController
  skip_before_action :authenticate_profile!

  def new
    # @profile = Profile.new
    @profiles = current_user.profiles
    redirect_to new_profile_path if current_user.profiles.empty?

    # gordana: this was in the old code but I don't think it's correct:
    # @profiles = current_user.profiles ? current_user.profiles : Profile.all
  end

  def create
    profile = Profile.find_by(id: params[:profile_id])
    if profile
      session[:profile_id] = profile.id
        if profile.companytype == "Immobiliària"
          redirect_to rentals_path
        elsif profile.companytype == "Lloguer turístic"
          redirect_to vrentals_path
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

  def log
  end
end
