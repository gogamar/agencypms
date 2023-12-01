class ContactFormMailer < ApplicationMailer
  default from: "Sistach Rentals <info@sistachrentals.com>"
  default to: 'info@sistachrentals.com'

  def contact_email(contact_form, company_language)
    @contact_form = contact_form
    @company_language = company_language
    mail(subject: t("contact_form_subject", locale: @company_language))
  end
end
