module ApplicationHelper
  include Pagy::Frontend

  def language_dropdown(current_locale)
    content_tag(:li, class: 'nav-item dropdown language-dropdown') do
      flag_code = set_flag(current_locale)
      concat(link_to("#", class: 'nav-link dropdown-toggle', id: 'languageDropdown', data: { bs_toggle: 'dropdown' }, 'aria-haspopup': true, 'aria-expanded': false) do
        content_tag(:span) do
          concat(content_tag(:span, nil, class: "flag-icon flag-icon-#{flag_code}"))
          concat(" #{t(current_locale)}")
        end
      end)

      concat(content_tag(:ul, class: 'dropdown-menu dropdown-menu-end', 'aria-labelledby': 'languageDropdown') do
        (I18n.available_locales - [current_locale]).each do |locale|
          flag_code = set_flag(locale)
          # Extract and preserve the current query parameters
          query_params = params.except(:locale, :page).permit!.to_h

          # query_params.each do |key, value|
          #   if key == "pf" || key == "pt"
          #     translation_keys = value.map { |el| I18n.backend.translations[params[:locale].to_sym].key(el) } if value.is_a?(Array)
          #     puts "translation_keys for #{value}: #{translation_keys}"
          #     query_params[key] = translation_keys.map { |el| I18n.t(el)}
          #   end
          # end
          # puts "query_params after translation: #{query_params}"

          # Generate the localized URL with preserved query parameters
          locale_path = url_for(locale: locale.to_s, **query_params)

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

  def stars_for_rating(rating)
    html = ''
    rating = rating.to_f
    filled_stars = rating.floor
    half_star = rating - filled_stars >= 0.5
    filled_stars.times do
      html << '<i class="fas fa-star fs-xs mx-1"></i>'
    end
    if half_star
      html << '<i class="fas fa-star-half-alt fs-xs mx-1"></i>'
    end
    (5 - filled_stars - (half_star ? 1 : 0)).times do
      html << '<i class="far fa-star fs-xs mx-1"></i>'
    end

    html.html_safe
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

  def whatsapp_link(phone_number)
    "https://wa.me/#{phone_number}"
  end

  def parent_route(current_route)
    segments = current_route.split('/')
    return root_path if segments.size <= 1

    parent_segments = segments[0...-1]
    parent_route = parent_segments.join('/')

    return parent_route
  end
end
