module ApplicationHelper
  include Pagy::Frontend

  def language_dropdown(current_locale)
    content_tag(:li, class: 'nav-item dropdown') do
      flag_code = set_flag(current_locale)
      concat(link_to("#", class: 'nav-link dropdown-toggle', id: 'languageDropdown', data: { bs_toggle: 'dropdown' }, 'aria-haspopup': true, 'aria-expanded': false) do
        content_tag(:small) do
          concat(content_tag(:span, nil, class: "flag-icon flag-icon-#{flag_code}"))
          concat(" #{t(current_locale)}")
        end
      end)

      concat(content_tag(:ul, class: 'dropdown-menu dropdown-menu-end', 'aria-labelledby': 'languageDropdown') do
        (I18n.available_locales - [current_locale]).each do |locale|
          flag_code = set_flag(locale)
          # Generate the localized URL using url_for with the locale parameter
          locale_path = url_for(locale: locale.to_s)

          concat(content_tag(:li) do
            concat(link_to(locale_path, class: 'dropdown-item') do
              concat(content_tag(:span, nil, class: "flag-icon flag-icon-#{flag_code}"))
              concat(" #{t(locale)}")
            end)
          end)
        end
      end)
    end
  end


  def set_flag(locale)
    if locale == :en
      flag_code = 'gb'
    elsif locale == :ca
      flag_code = 'es-ca'
    else
      flag_code = locale
    end
    return flag_code
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
   @devise_mapping ||= Devise.mappings[:user]
  end

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
