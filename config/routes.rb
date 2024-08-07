require "sidekiq/web"
require 'sidekiq/cron/web'

Rails.application.routes.draw do

  namespace :api do
    match 'webhooks', to: 'webhooks#handle_notification', via: [:get, :post]
  end

  resources :image_urls do
    member do
      patch :move
    end
  end

  resources :job_records, only: [:create, :update, :destroy]
  get 'job_records/status', to: 'job_records#status', as: 'job_status'
  get 'cleaning_schedules/load_pdf_modal', to: 'cleaning_schedules#load_pdf_modal'
  post 'cookie_consent', to: 'pages#cookie_consent', as: 'cookie_consent'

  mount Ckeditor::Engine => '/ckeditor'

  localized do
    # Sidekiq Web UI, only for admins.
    authenticate :user, ->(user) { user.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
    devise_for :users, controllers: { registrations: 'users/registrations' }
    resources :users, only: [:index, :update, :destroy]
    root to: "pages#home", as: :root
    resources :tasks
    resources :tourists
    resources :regions
    resources :towns
    resources :feeds
    resources :categories, except: [:show] do
      resources :posts, only: [:show, :index]
      get 'news', to: 'pages#news', as: 'news'
    end
    resources :posts do
      patch 'toggle_hidden', on: :member
    end
    resources :rate_plans do
      member do
        post :upload_rate_dates
        get :delete_periods
      end
      resources :rate_periods
    end
    resources :companies do
      resources :offices, except: [:destroy] do
        member do
          get "organize_cleaning"
          get "cleaning_checkout"
          get "cleaning_checkin"
        end
        resources :coupons, only: [:new, :create, :index, :edit, :update] do
          member do
            get 'apply_to_all'
          end
        end
      end
    end


    resources :vrentals do
      collection do
        get 'list'
        get 'total_earnings'
        get 'list_earnings'
        get 'total_city_tax'
        get 'download_city_tax'
      end

      member do
        get :add_owner
        get :add_booking_conditions
        get :add_descriptions
        get :add_features
        get :add_bedrooms_bathrooms
        get :annual_statement
        get :fetch_earnings
        post :upload_dates
        post :copy_images
        get :add_photos
        get :copy
        get :copy_rates
        get :send_rates
        get :export_beds
        get :update_on_beds
        get :send_photos
        get :import_photos
        get :update_from_beds
        get :update_owner_from_beds
        get :get_rates
        get :delete_rates
        get :delete_year_rates
        get :get_bookings
        get :prevent_gaps
        get :import_from_group
        get :get_availabilities_from_beds
        get :bookings_on_calendar
        get :get_reviews_from_airbnb
        patch :toggle_featured
        get :restriction_rates
        get :delete_all_photos
      end

      resources :availabilities, except: [:show]
      resources :statements
      resources :invoices
      resources :owners, only: [:new, :create, :edit, :update]

      resources :earnings, only: [:new, :edit, :create, :update, :index, :show] do
        member do
          get 'unlock'
        end
      end
      resources :expenses
      resources :owner_bookings, only: [:new, :edit, :create, :update, :index] do
        member do
          get 'show_form'
        end
      end

      resources :bathrooms
      resources :bedrooms do
        resources :beds
      end

      resources :bookings do
        resources :payments
        resources :charges
        member do
          get 'show_booking'
        end
      end
      resources :rates, only: [:new, :edit, :create, :update, :index, :show]
      resources :vragreements do
        member do
          get 'copy'
          patch 'sign_contract'
        end
        resources :photos, only: :destroy, shallow: true
      end

    end

    resources :expenses, only: [:new, :create, :index, :destroy]
    resources :earnings, only: [:index, :destroy]
    resources :invoices, only: [:index, :destroy] do
      collection do
        get 'download_all'
      end
    end

    resources :owners do
      collection do
        get 'filter'
      end
      member do
        get 'grant_access'
        get 'remove_access'
        get 'send_access_email'
      end
    end

    resources :vrentaltemplates do
      member do
        get 'copy'
      end
    end

    resources :vragreements, only: [:show, :index, :destroy] do
      collection do
        get 'list'
      end
    end

    resources :rates, only: :destroy
    resources :earnings, only: :destroy
    resources :statements do
      resources :owner_payments
    end

    resources :vrgroups do
      member do
        get :prevent_gaps
      end
    end

    resources :features
    resources :features_vrentals

    resources :coupons, only: [:destroy]
    resources :coupons_vrentals

    resources :cleaning_companies

    resources :offices, only: [:destroy] do
      resources :cleaning_schedules do
        member do
          get 'unlock'
        end
        collection do
          post :update_all
        end
      end
      member do
        get "import_bookings"
        get "import_properties"
        get "destroy_all_properties"
        get "get_reviews_from_airbnb"
      end
    end

    get 'contact', to: 'contact_forms#new', as: 'contact'
    post 'contact_forms', to: 'contact_forms#create'
    get 'about', to: 'pages#about'
    get 'list', to: 'pages#list'
    get 'sort_properties', to: 'pages#sort_properties'
    get 'privacy_policy', to: 'pages#privacy_policy'
    get 'terms_of_service', to: 'pages#terms_of_service'
    get 'book/:id', to: 'pages#book_property', as: 'book_property'
    get 'confirm_booking', to: 'pages#confirm_booking'
    get 'get_availability', to: 'pages#get_availability'
    get 'get_checkout_dates', to: 'pages#get_checkout_dates'
    get 'home', to: 'pages#home'
    get 'terms', to: 'pages#terms'
    get 'dashboard', to: 'vrentals#dashboard'
    get 'empty_vrentals', to: 'vrentals#empty_vrentals'
    get 'news', to: 'pages#news', as: 'news'
    get 'news/:id', to: 'pages#news_post', as: 'news_post'
    get 'get_news', to: 'posts#get_news'
    get '*path' => 'application#redirect_to_homepage'
  end
  get '/ca', to: redirect('/'), as: :redirect_default_locale
  get '*path' => 'application#redirect_to_homepage'
end
