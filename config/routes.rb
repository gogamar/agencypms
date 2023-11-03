Rails.application.routes.draw do

  # scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    resources :image_urls do
      member do
        patch :move
      end
    end
    resources :rate_plans do
      member do
        post :upload_rate_dates
        get :delete_periods
      end
      resources :rate_periods
    end

    localized do
      devise_for :users
      resources :users
      root to: "pages#home", as: :root
      resources :tasks
      resources :tourists
      resources :towns
      resources :bathrooms
      resources :beds
      resources :bedrooms
      resources :companies do
        resources :offices, except: [:destroy]
      end
      resources :offices, only: [:destroy] do
        member do
          get "import_properties"
          get "destroy_all_properties"
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
          get :add_features
          get :annual_statement
          get :fetch_earnings
          post :upload_dates
          get :edit_photos
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
          get :import_from_group
        end

        resources :statements
        resources :invoices
        resources :owners, only: [:new, :create, :edit, :update]

        resources :earnings, only: [:new, :edit, :create, :update, :index, :show] do
          member do
            get 'unlock'
          end
        end
        resources :expenses

        resources :bookings do
          resources :payments
          resources :charges
        end

        resources :rates, only: [:new, :edit, :create, :update, :index, :show]
        resources :vragreements, only: [:new, :edit, :create, :update, :show, :index] do
          member do
            get 'copy'
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
      end

      resources :vrentaltemplates do
        member do
          get 'copy'
        end
      end

      resources :vragreements, only: [:index, :destroy, :show] do
        collection do
          get 'list'
        end
      end

      resources :rates, only: :destroy
      resources :earnings, only: :destroy
      resources :statements do
        resources :owner_payments
      end

      resources :vrgroups

      resources :features
      resources :features_vrentals

      mount Ckeditor::Engine => '/ckeditor'

      get 'about', to: 'pages#about'
      get 'list_map', to: 'pages#list_map'
      get 'list', to: 'pages#list'
      get 'filter', to: 'pages#filter'
      get 'sort_properties', to: 'pages#sort_properties'
      get 'book_property', to: 'pages#book_property'
      get 'confirm_booking', to: 'pages#confirm_booking'
      get 'contact', to: 'pages#contact'
      get 'home', to: 'pages#home'
      get 'dashboard', to: 'pages#dashboard'
      get 'terms', to: 'pages#terms'
      get 'get_availability', to: 'pages#get_availability'
      get 'submit_property', to: 'pages#submit_property'
    end
  # end
  get '/ca', to: redirect('/'), as: :redirect_default_locale
end
