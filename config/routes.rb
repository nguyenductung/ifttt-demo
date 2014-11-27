Rails.application.routes.draw do
  resources :pages
  resources :users
  resources :sessions
  root "sessions#new"
  match "/auth/:provider/callback", to: "sessions#create", via: :get
  match "/signin", to: "sessions#new", as: :sign_in, via: :get
  match "/signout", to: "sessions#destroy", as: :sign_out, via: :delete
end
