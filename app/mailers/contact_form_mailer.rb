class ContactFormMailer < ApplicationMailer
  default to: 'gogamar@gmail.com'

  def contact_email(contact_form, company_language)
    @contact_form = contact_form
    @company_language = company_language
    mail(subject: t("contact_form_subject", locale: @company_language))
  end
end
