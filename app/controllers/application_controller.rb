class ApplicationController < ActionController::Base
  before_action :set_locale
  around_action :set_locale_from_url
  before_action :authenticate_user!
  before_action :set_vrentals, unless: :skip_pundit?
  before_action :set_company, unless: :companies_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_admin_area
  before_action :set_estartit_office

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
    devise_parameter_sanitizer.permit(:sign_up, keys: [:photo, :company_id, :title, :firstname, :lastname, :company_name])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:photo, :company_id, :title, :firstname, :lastname, :company_name])
  end

  def set_company
    @company = Company.find_by(active: true)
  end

  def companies_controller?
    controller_name == 'companies'
  end

  private

  def set_vrentals
    @all_vrentals = policy_scope(Vrental)
  end

  def set_estartit_office
    @estartit_office = Office.where("name ILIKE ?", '%estartit%')&.first
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
    if current_user.admin? || current_user.manager? || current_user.owner.present?
      vrentals_path
    else
      new_vrental_path
    end
  end

  # Uncomment when you *really understand* Pundit!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def user_not_authorized
    flash[:alert] = "No estàs autoritzat per procedir amb aquesta acció."
    redirect_back(fallback_location: root_path)
  end

  def skip_pundit?
    devise_controller? ||
      params[:controller] =~ /(^(rails_)?admin)|(^registrations$)|(^pages$)|(^contact_forms$)|(^api\/webhooks$)/
  end

  def set_admin_area
    @admin_area = true
  end
end
