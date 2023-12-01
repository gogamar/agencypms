class ApplicationController < ActionController::Base
  before_action :set_locale
  around_action :set_locale_from_url
  before_action :authenticate_user!
  before_action :set_vrentals, unless: :skip_pundit?
  before_action :set_company
  before_action :configure_permitted_parameters, if: :devise_controller?
  layout :layout_by_resource

  include Pundit::Authorization
  include Pagy::Backend

  # Pundit: allow-list approach
  after_action :verify_authorized, except: [:index, :list, :filter, :import_properties], unless: :skip_pundit?
  after_action :verify_policy_scoped, only: [:index, :list, :filter, :import_properties], unless: :skip_pundit?

  def redirect_to_homepage
    skip_authorization
    redirect_to root_path
  end

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :photo, :approved, :company_id])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:role, :photo, :approved, :company_id])
  end

  private

  def set_vrentals
    @all_vrentals = policy_scope(Vrental)
  end

  def set_company
    # fixme: this is a hack to get the company
    @company = Company.first
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
    vrentals_path
  end

  # Uncomment when you *really understand* Pundit!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def user_not_authorized
    flash[:alert] = "No estàs autoritzat per procedir amb aquesta acció."
    redirect_back(fallback_location: root_path)
  end

  def skip_pundit?
    devise_controller? ||
      params[:controller] =~ /(^(rails_)?admin)|(^pages$)|(^contact_forms$)|(^api\/webhooks$)/
  end

  def layout_by_resource
    if devise_controller?
      "booking_website"
    else
      "application"
    end
  end
end
