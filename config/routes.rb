Rw2::Application.routes.draw do

  get "measures/show"
  get "measures/index"
  get "measures/create"
  root 'pages#home'

  devise_for :users
  resources :users


  get "/stations/:station_id/measures", to: "measures#station_index", as: :station_measures

  resources :stations, :shallow => true do
    resources :measures, only: [:show, :create, :destroy] do |measure|
    end
  end

  resources :measures,  only: [:index, :create]


end
