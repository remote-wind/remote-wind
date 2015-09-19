RemoteWind::Application.routes.draw do

  root 'pages#home'
  get '/honeypot', to: "application#honeypot", as: :honeypot
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

  resources :users do
    resources :roles, only: [:create, :destroy] do
    end
    resources :notifications, only: [:index, :destroy] do
      collection do
        patch '/', action: :update_all
        delete '/', action: :destroy_all
      end
    end
  end

  # Legacy routes to support Ardiuno stations
  put '/s/:id' => 'stations#update_balance', constraints: { format: :yaml }
  post '/measures' => 'observations#create', constraints: { format: :yaml }


  get 'stations/find/:hw_id', to: "stations#find", as: :find_station

  resources :stations do
    collection do
      # Used by Ardiuno station to lookup ID
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

    resources :observations, only: [:index, :create, :destroy] do |measure|
      collection do
        delete '/',
          to: "observations#clear",
          as: :destroy
      end
    end
  end
end
