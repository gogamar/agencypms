Rails.application.routes.draw do
  get 'features/new'
  get 'features/index'
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root to: "pages#home"
    devise_for :users

    resources :users do
      member do
        delete :purge_photo
      end
    end


    resources :profiles do
      member do
      delete :purge_photo
      end
    end

    resources :profile_sessions, only: [:new, :create]

    # resources for real estate companies
    resources :owners
    resources :rentals do
        resources :agreements
    end
    resources :renters
    resources :rentaltemplates
    resources :agreements


    # resources for vacation rentals companies
    resources :vrowners
    resources :vrentals do
      resources :rates, only: [:new, :edit, :create, :update]
      resources :features, only: [:new, :edit, :create, :update]
      resources :vragreements, only: [:new, :edit, :create, :update]
      member do
        get 'copy'
      end
    end
    resources :vrentaltemplates do
      member do
        get 'copy'
      end
    end
    resources :vragreements, only: [:show, :index, :delete]
    resources :rates
    resources :features


    mount Ckeditor::Engine => '/ckeditor'


    # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  end
end
