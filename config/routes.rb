Rails.application.routes.draw do
  get "dashboard", to: "dashboard#index", as: "dashboard"
  get "home/index"
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

  # Defines the root path route ("/")
  root "home#index"
end
