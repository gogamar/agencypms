class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :authenticate_user!
  # before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_profile!
  skip_before_action :authenticate_profile!, if: :devise_controller?
  helper_method :current_profile
  include ProfileSessionHelper

  include Pundit::Authorization

  # Pundit: allow-list approach
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Uncomment when you *really understand* Pundit!
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # def user_not_authorized
  #   flash[:alert] = "You are not authorized to perform this action."
  #   redirect_to(root_path)
  # end



  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :photo])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :photo])
  end

  private

  def default_url_options
    { locale: I18n.locale }
  end

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end
  def extract_locale
    parsed_locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  def authenticate_profile!
    @current_profile = Profile.find_by(id: session[:profile_id])
    redirect_to new_profile_session_path if @current_profile.nil?
  end

  def after_sign_in_path_for(_resource)
    root_path
  end


  def current_profile
    @current_profile
  end

  def logged_in_profile
    unless profile_logged_in?
      store_location
      flash[:danger] = "Si us plau selecciona el perfil"
      redirect_to new_profile_session_path
    end
  end

  def user_not_authorized
    flash[:alert] = "No estàs autoritzat per procedir amb aquesta acció."
    redirect_back(fallback_location: root_path)
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
end
