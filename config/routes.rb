Rails.application.routes.draw do
  get 'auth/:provider/callback', to: 'sessions#create'
  get '/login', to: 'sessions#new'

  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token, only: %i[new create edit update]
  constraints(id: %r{[^/]+}) do
    resources :subjects, export: true, only: %i[index show]
    resources :authors, export: true, only: %i[show]
    resources :papers, export: true, only: %i[show]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "subjects#show"
end
