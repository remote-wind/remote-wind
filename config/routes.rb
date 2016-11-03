RemoteWind::Application.routes.draw do

  root 'pages#home'
  get '/products', to: "pages#products", as: :products

  delete '/users/:user_id/roles(/:id)', to: 'roles#destroy', as: :destroy_user_role

  devise_for :users, skip: [:sessions], controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks',
      registrations: "users/registrations"
  }

  as :user do
    get 'signin' => 'devise/sessions#new', as: :new_user_session
    post 'signin' => 'devise/sessions#create', as: :user_session
    match 'signout' => 'devise/sessions#destroy', as: :destroy_user_session,
          via: [:GET, :DELETE]
  end

  resources :users, except: [:new]

  resources :notifications, only: [:index, :destroy] do
    collection do
      patch '/', action: :update_all
      delete '/', action: :destroy_all
    end
  end

  # Used by Ardiuno stations to lookup ID
  get 'stations/find/:hw_id', to: "stations#find", as: :find_station
  # Used by Arduino stations to report firmwares
  put   'stations/:id/firmware_version', to: 'stations#api_firmware_version', constraints: { format: :json }
  patch 'stations/:id/firmware_version', to: 'stations#api_firmware_version', constraints: { format: 'json' }

  resources :stations do
    collection do
      # Proximity search - not in use
      get '/search/(:lon)(/:lat)(/:radius)',
          to: 'stations#search',
          as: :search
    end
    member do
      get '/embed(/:css)',
          to: 'stations#embed',
          as: :embed
    end

    resources :observations, only: [:index, :create, :destroy] do
      collection do
        delete '/',
          to: "observations#clear",
          as: :destroy
      end
    end
  end
end
