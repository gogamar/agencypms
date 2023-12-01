class AdminMailer < ApplicationMailer
  default from: "Sistach Rentals <info@sistachrentals.com>"
  layout 'mailer'

  def new_user_waiting_for_approval(email)
    @email = email
    mail(to: 'info@sistachrentals.com', subject: 'Hi ha un usuari nou esperant l\'aprovació de l\'administrador')
  end
end
