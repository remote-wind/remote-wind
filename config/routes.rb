Rw2::Application.routes.draw do

  root 'pages#home'

  devise_for :users
  resources :users
  resources :stations

end
