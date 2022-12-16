Rails.application.routes.draw do

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    scope(path_names: { new: 'nou', edit: 'modificar', sign_in: 'entrar', sign_up: 'registrar_se', password: 'contrasenya'}) do
      root to: "pages#home"
      devise_for :users, path: 'usuaris'
      resources :tasks, path: 'cites'
      resources :comtypes, path: 'tipus-empresa', only: [:new, :create, :edit, :update, :index, :destroy]

      resources :users, path: 'usuaris' do
        member do
          delete :purge_photo
        end
      end

      resources :profiles, path: 'perfils' do
        member do
          delete :purge_photo
        end
      end

      resources :profile_sessions, path: 'sessio-perfil', only: [:new, :create]

      # resources for real estate companies (rentals)

      resources :owners, path: 'propietaris-lloguer-anual' do
        collection do
          get 'filter'
        end
      end

      resources :rentals, path: 'immobles-lloguer-anual' do
        collection do
          get 'list'
        end
        resources :agreements, path: 'contractes-lloguer-anual', only: [:new, :edit, :create, :update ]
        member do
          get 'copy'
        end
      end

      resources :renters, path: 'llogaters-anuals' do
        collection do
          get 'filter'
        end
      end

      resources :rentaltemplates, path: 'models-de-contracte-lloguer-anual' do
        member do
          get 'copy'
        end
      end

      resources :agreements, path: 'contractes-lloguer-anual', only: [:index, :destroy, :show] do
        collection do
          get 'list'
        end
      end

      # resources for real estate companies (sales)

      resources :sellers, path: 'venedors' do
        collection do
          get 'filter'
        end
      end

      resources :realestates, path: 'immobles-compravenda' do
        collection do
          get 'list'
        end
        resources :contracts, path: 'contractes-compravenda', only: [:new, :edit, :create, :update ]
        member do
          get 'copy'
        end
      end

      resources :buyers, path: 'compradors' do
        collection do
          get 'filter'
        end
      end

      resources :rstemplates, path: 'models-de-contracte-compravenda' do
        member do
          get 'copy'
        end
      end

      resources :contracts, path: 'contractes-compravenda', only: [:index, :destroy, :show] do
        collection do
          get 'list'
        end
      end


      # resources for vacation rentals companies
      resources :vrowners, path: 'propietaris-lloguer-turistic' do
        collection do
          get 'filter'
        end
      end

      resources :vrentals, path: 'immobles-lloguer-turistic' do
        collection do
          get 'list'
        end
        resources :rates, path: 'tarifes', only: [:new, :edit, :create, :update, :index, :show]
        resources :vragreements, path: 'contractes-lloguer-turistic', only: [:new, :edit, :create, :update] do
          resources :photos, only: :destroy, shallow: true
        end
        member do
          get 'copy'
          get 'copy_rates'
          get 'send_rates'
        end
      end

      resources :vrentaltemplates, path: 'models-de-contracte-lloguer-turistic' do
        member do
          get 'copy'
        end
      end

      resources :vragreements, path: 'contractes-lloguer-turistic', only: [:index, :destroy, :show] do
        collection do
          get 'list'
        end
      end

      resources :rates, path: 'tarifes', only: :destroy

      resources :features, path: 'caracteristiques'

      resources :features_vrentals, path: 'caracteristiques-lloguer-turistic'


      mount Ckeditor::Engine => '/ckeditor'

      # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
    end
  end
end
