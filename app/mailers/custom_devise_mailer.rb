class CustomDeviseMailer < Devise::Mailer
  default from: "Sistach Rentals <info@sistachrentals.com>"
  layout 'mailer'

  def send_owner_access(user, office)
    @user = user
    @office = office
    @token = user.send(:set_reset_password_token)
    mail(to: user.email, subject: t('welcome_owner_space')) do |format|
      format.html { render 'custom_devise_mailer/send_owner_access' }
    end
  end
end
