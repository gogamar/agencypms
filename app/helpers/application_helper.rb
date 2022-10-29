module ApplicationHelper
  def errors_for(model, key)
    tag.div(class: "mt-2 form-error") do
      model.errors.messages_for(key).join(", ")
    end
  end

  def inline_error_for(field, form_obj)
    html = []
    if form_obj.errors[field].any?
      html << form_obj.errors[field].map do |msg|
        tag.div(msg, class: "mt-2 form-error")
      end
    end
    html.join.html_safe
  end
end
