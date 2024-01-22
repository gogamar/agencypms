class CustomDeviseMailer < Devise::Mailer
  default from: "Sistach Rentals <info@sistachrentals.com>"
  layout 'mailer'

  def grant_owner_access_reset_password(user)
    @user = user
    mail(to: user.email, subject: t('welcome_owner_space')) do |format|
      format.html { render 'custom_devise_mailer/send_owner_access' }
    end
  end
end
