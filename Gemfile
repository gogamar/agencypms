source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
gem "hotwire-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
gem "sassc-rails"

# Gem for excel download
gem 'caxlsx'
gem 'caxlsx_rails'

# Geocoder
gem 'geocoder'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem "devise"
gem "autoprefixer-rails"
gem "simple_form", github: "heartcombo/simple_form"
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "dotenv-rails"
  # gem 'i18n-debug'

end

group :development do
  gem "wkhtmltopdf-binary"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem 'letter_opener'
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  # gem "webdrivers"
end

# don't know if I need cssbundling
# gem "cssbundling-rails"
# gem 'flatpickr_rails', '~> 1.1'
gem 'rails-i18n'
gem 'bootstrap-datepicker-rails'
gem "cloudinary"
gem "mini_magick"
gem 'ckeditor'
gem 'beds24', github: 'gogamar/beds24'
gem 'wicked_pdf'
gem 'devise-i18n'
gem 'flag-icons-rails'
gem 'pry-byebug'
gem 'rails-html-sanitizer'
gem "pundit"
gem "font-awesome-sass", "~> 6.1"
gem 'pagy', '~> 5.10'
gem "simple_calendar", "~> 2.4"
gem "acts_as_list", "~> 1.1"
gem 'lightbox2'
gem 'route_translator'
gem 'recaptcha'
gem 'cocoon'
gem 'ferrum'
gem 'nokogiri'
gem 'sidekiq'
gem "sidekiq-cron"


# for heroku stack heroku-22
group :production do
    gem 'wkhtmltopdf-heroku', '2.12.6.1.pre.jammy'
end
