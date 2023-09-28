Rails.application.routes.draw do

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    scope(path_names: { new: 'nou', edit: 'modificar', sign_in: 'entrar', sign_up: 'registrar_se', password: 'contrasenya'}) do
      root to: "vrentals#index"
      devise_for :users, path: 'usuaris'
      resources :tasks, path: 'cites'

      resources :users, path: 'usuaris' do
        member do
          delete :purge_photo
        end
      end

      resources :tourists, path: 'clients'

      resources :companies, path: 'empreses' do
        resources :offices, path: 'oficines', except: [:destroy]
      end

      resources :rate_plans, path: 'plans' do
        resources :rate_periods, path: 'periods'
      end

      resources :offices, path: 'oficines', only: [:destroy]

      resources :vrentals, path: 'immobles-lloguer-turistic' do
        collection do
          get 'list'
          get "import_properties"
          get 'total_earnings'
          get 'list_earnings'
        end

        member do
          get :add_vrowner
          get :add_features
          get :annual_statement, path: 'liquidacio-annual'
          get :fetch_earnings
        end
        resources :statements, path: 'liquidacions'
        resources :invoices, path: 'factures'
        resources :vrowners, path: 'propietaris-lloguer-turistic', only: [:new, :create, :edit, :update]

        resources :earnings, path: 'ingressos', only: [:new, :edit, :create, :update, :index, :show] do
          member do
            get 'unlock'
          end
        end
        resources :expenses, path: 'despeses'

        resources :bookings do
          resources :payments
          resources :charges
        end
        resources :rates, path: 'tarifes', only: [:new, :edit, :create, :update, :index, :show]
        resources :vragreements, path: 'contractes-lloguer-turistic', only: [:new, :edit, :create, :update, :show, :index] do
          member do
            get 'copy'
          end
          resources :photos, only: :destroy, shallow: true
        end
        member do
          get 'copy'
          get 'copy_rates'
          get 'send_rates'
          get 'export_beds'
          get 'update_beds'
          get 'get_rates'
          get 'delete_rates'
          get 'delete_year_rates'
          get 'get_bookings'
        end
      end
      resources :expenses, path: 'despeses', only: [:new, :create, :index, :destroy]
      resources :earnings, path: 'ingressos', only: [:index, :destroy]
      resources :invoices, path: 'factures', only: [:index, :destroy]
      resources :vrowners, path: 'propietaris-lloguer-turistic' do
        collection do
          get 'filter'
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
      resources :earnings, path: 'ingressos', only: :destroy
      resources :statements, path: 'liquidacions' do
        resources :vrowner_payments, path: 'pagaments-lloguer-turistic'
      end

      resources :features, path: 'caracteristiques'

      resources :features_vrentals, path: 'caracteristiques-lloguer-turistic'

      mount Ckeditor::Engine => '/ckeditor'
    end
  end
end
