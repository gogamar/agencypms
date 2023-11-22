class UserMailer < ApplicationMailer

  def welcome(user)
    # @greeting = "Hi"
    # @user = user
    @user = params[:user]
    mail(to: @user.email, subject: t('user_mailer.welcome.subject'))
  end
end
