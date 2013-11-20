Rw2::Application.routes.draw do

  root 'pages#home'
  get '/products', to: "pages#products", as: :products

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :users

  get "/stations/:station_id/measures", to: "stations#measures", as: :station_measures
  delete "/stations/:station_id/measures", to: "stations#destroy_measures", as: :station_measures_destroy

  resources :stations, :shallow => true do
    resources :measures, only: [:show, :create, :destroy] do |measure|
    end
  end
  resources :measures,  only: [:index, :create]

end
