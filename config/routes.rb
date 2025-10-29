Rails.application.routes.draw do
  # Authentication routes
  get "signup", to: "registrations#new", as: "signup"
  post "signup", to: "registrations#create"
  get "login", to: "sessions#new", as: "login"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"

  # Components showcase
  get "components", to: "components#index", as: "components"

  # Theme generator
  get "theme-generator", to: "theme_generator#index", as: "theme_generator"

  # Dashboard
  get "dashboard", to: "dashboard#index", as: "dashboard"
  get "home/index"

  # Agent orchestration routes
  namespace :api do
    namespace :v1 do
      resources :agents do
        member do
          post :activate
          post :deactivate
          post :heartbeat
        end
        collection do
          get :stats
        end
      end

      resources :tasks do
        member do
          post :retry_task
          post :cancel
        end
        collection do
          post :batch_create
          get :stats
          get :dead_letter
        end
      end

      namespace :monitoring do
        get :dashboard
        get 'agents/:id/metrics', to: 'monitoring#agent_metrics'
        get :quality_report
        get :memory_stats
        get :health
      end
    end
  end

  # Agent admin UI
  get "agents", to: "agents#index", as: "agents"
  get "agents/:id", to: "agents#show", as: "agent"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Spreadsheet routes
  resources :spreadsheets do
    resources :sheets do
      member do
        post :add_column
        delete 'remove_column/:column_key', to: 'sheets#remove_column', as: :remove_column
      end

      # Nested routes for rows and cells
      post 'rows', to: 'cells#create_row', as: :create_row
      delete 'rows/:row_id', to: 'cells#destroy_row', as: :destroy_row
      patch 'rows/:row_id/cells/:column_key', to: 'cells#update', as: :update_cell
    end
  end

  # N8n-compatible Workflow API routes
  resources :workflows do
    member do
      post :execute
      post :activate
      post :deactivate
    end

    collection do
      get :templates
      post :from_template
    end
  end

  # Workflow executions
  resources :workflow_executions, only: [:index, :show] do
    member do
      post :cancel
    end
  end

  # N8n integration endpoints
  namespace :api do
    namespace :v1 do
      namespace :n8n do
        post 'import', to: 'integration#import'
        get 'export/:id', to: 'integration#export'
        post 'validate', to: 'integration#validate'
      end
    end
  end

  # Agricultural Platform "Kod Urozhaya" (Harvest Code) routes
  get 'agro', to: 'agro_platform#index', as: 'agro_platform'
  get 'agro/ecosystem', to: 'agro_platform#ecosystem', as: 'agro_platform_ecosystem'
  get 'agro/monitoring', to: 'agro_platform#monitoring', as: 'agro_platform_monitoring'

  # Agricultural Agents
  resources :agro_agents do
    member do
      post :heartbeat
    end
  end

  # Agricultural Tasks
  resources :agro_tasks, only: [:index, :show, :new, :create] do
    member do
      post :retry
    end
  end

  # Farms
  resources :farms

  # Market Offers (Supply/Demand)
  resources :market_offers do
    collection do
      post :match
    end
  end

  # Smart Contracts
  resources :smart_contracts, only: [:index, :show]

  # Agent Coordinations
  resources :agent_coordinations, only: [:index, :show]

  # Defines the root path route ("/")
  root "home#index"
end
