Rw2::Application.routes.draw do

  get "measures/show"
  get "measures/index"
  get "measures/create"
  root 'pages#home'

  devise_for :users
  resources :users
  resources :stations
  resources :measures
end
