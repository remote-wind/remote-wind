Rw2::Application.routes.draw do

  root 'pages#home'

  devise_for :users
  resources :users


  get "/stations/:station_id/measures", to: "stations#measures", as: :station_measures

  resources :stations, :shallow => true do
    resources :measures, only: [:show, :create, :destroy] do |measure|
    end
  end

  resources :measures,  only: [:index, :create]


end
