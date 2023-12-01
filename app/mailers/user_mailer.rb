class UserMailer < ApplicationMailer
  default from: "Sistach Rentals <info@sistachrentals.com>"

  def welcome(user, web)
    @web = web
    @user = user
    mail(to: @user.email, subject: t('user_mailer.welcome.subject'))
  end
end
