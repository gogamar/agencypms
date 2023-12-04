class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]

  private

  def check_captcha
    return if verify_recaptcha

    self.resource = resource_class.new sign_up_params
    resource.validate # Look for any other validation errors besides reCAPTCHA
    set_minimum_password_length

    respond_with_navigational(resource) do
      flash[:recaptcha_error] = "reCAPTCHA verification failed. Please try again."
      redirect_to new_user_registration_path
    end
  end
end
