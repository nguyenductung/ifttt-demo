Rails.application.routes.draw do
  resources :pages
  resources :sessions
  root "pages#index"
  match "/auth/:provider/callback", to: "sessions#create", via: :get
end
