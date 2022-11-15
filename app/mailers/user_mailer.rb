class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome
    # @greeting = "Hi"
    # @user = user
    @user = params[:user] # Instance variable => available in view
    mail(to: @user.email, subject: 'Benvingut/da a la aplicació per fer contractes de Sistach Finques')
  end
end
