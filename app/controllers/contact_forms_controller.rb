class ContactFormsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @contact_form = ContactForm.new
  end

  def create
    @contact_form = ContactForm.new(contact_form_params)

    if verify_recaptcha(model: @contact_form) && @contact_form.save
      @company = Company.first
      @company_language = @company.language
      ContactFormMailer.contact_email(@contact_form, @company_language).deliver_now
      redirect_to root_path, notice: t('contact_form_success')
    else
      render :new
    end
  end

  private

  def contact_form_params
    params.require(:contact_form).permit(:name, :email, :subject, :message)
  end
end
