require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Contractes
  class Application < Rails::Application
    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :test_unit, fixture: false
    end
    # Initialize configuration defaults for originally generated Rails version.

    config.load_defaults 7.0
    config.i18n.available_locales = [:ca, :es, :fr, :en]
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]

    config.i18n.default_locale = :ca

    # allowing html tags and attributes so that sanitize doesn't strip it all
    # config.action_view.sanitized_allowed_tags = ['strong', 'em', 'a', 'tr', 'td', 'th', 'table', 'thead', 'tbody', 'hr', 'span']
    # config.action_view.sanitized_allowed_attributes = ['href', 'title', 'colspan', 'style', 'class']

    config.action_view.sanitized_allowed_attributes = Rails::Html::SafeListSanitizer.allowed_attributes = ['href', 'title', 'colspan', 'style', 'class', 'src']
    config.action_view.sanitized_allowed_tags = Rails::Html::SafeListSanitizer.allowed_tags = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'div', 'img', 'strong', 'em', 'a', 'tr', 'td', 'th', 'table', 'thead', 'tbody', 'hr', 'span']


    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
