module ProfileSessionHelper
  def profile_log_in(profile)
    session[:profile_id] = profile.id
  end

  def current_profile
    if session[:profile_id]
      @current_profile ||= Profile.find_by(id: session[:profile_id])
    end
  end

  def profile_logged_in?
    !current_profile.nil?
  end

  def profile_log_out
    session.delete(:profile_id)
    @current_profile = nil
  end

  def current_profile?(profile)
    profile == current_profile
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
