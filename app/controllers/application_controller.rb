class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :authenticate_user!
  before_action :set_vrentals, unless: :skip_pundit?
  # before_action :configure_permitted_parameters, if: :devise_controller?

  include Pundit::Authorization
  include Pagy::Backend

  # Pundit: allow-list approach
  after_action :verify_authorized, except: [:index, :list, :filter, :import_properties], unless: :skip_pundit?
  after_action :verify_policy_scoped, only: [:index, :list, :filter, :import_properties], unless: :skip_pundit?



  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :photo])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :photo])
  end

  private

  def set_vrentals
    @vrentals = policy_scope(Vrental)
  end

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

  def after_sign_in_path_for(_resource)
    root_path
  end

  # Uncomment when you *really understand* Pundit!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def user_not_authorized
    flash[:alert] = "No estàs autoritzat per procedir amb aquesta acció."
    redirect_back(fallback_location: root_path)
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
end
