module ApplicationHelper
  include Pagy::Frontend

  # def inline_error_for(field, form_obj)
  #   html = []
  #   if form_obj.errors[field].any?
  #     html << form_obj.errors[field].map do |msg|
  #       tag.div(msg, class: "mt-2 form-error-2")
  #     end
  #   end
  #   html.join.html_safe
  # end
end
