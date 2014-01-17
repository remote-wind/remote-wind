RemoteWind::Application.routes.draw do

  root 'pages#home'
  get '/honeypot', to: "application#honeypot", as: :honeypot
  get '/products', to: "pages#products", as: :products

  delete '/users/:user_id/roles(/:id)', to: 'roles#destroy', as: :destroy_user_role

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :users do
    resources :roles, only: [:create, :destroy] do
    end
  end

  get "/stations/:station_id/measures", to: "stations#measures", as: :station_measures
  get "/stations/:station_id/embed(/:css)", to: "stations#embed", as: :embed_station
  delete "/stations/:station_id/measures", to: "stations#destroy_measures", as: :destroy_station_measures

  get "/stations/find/:hw_id", to: "stations#find", as: :find_station
  resources :stations, shallow: true do
    resources :measures, only: [:show, :create, :destroy]
  end

  get "/stations/:station_id/measures/page/:page", to: "stations#measures", as: :station_measures_paginate
  get "/stations/search/(:lon)(/:lat)(/:radius)", to: "stations#search", as: :search_stations

  resources :measures,  only: [:index, :create]

end
