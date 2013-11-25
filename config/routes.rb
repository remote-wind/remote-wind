RemoteWind::Application.routes.draw do

  root 'pages#home'
  get '/honeypot', to: "application#honeypot", as: :honeypot
  get '/products', to: "pages#products", as: :products

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :users do
    resources :roles, only: [:create, :destroy] do

    end
  end

  get "/stations/:station_id/measures", to: "stations#measures", as: :station_measures
  delete "/stations/:station_id/measures", to: "stations#destroy_measures", as: :destroy_station_measures

  resources :stations, :shallow => true do
    resources :measures, only: [:show, :create, :destroy] do |measure|
    end
  end

  get "/stations/search/(:lon)(/:lat)(/:radius)", to: "stations#search", as: :search_stations

  resources :measures,  only: [:index, :create]

end
