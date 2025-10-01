Rails.application.routes.draw do
  #get 'auth/:provider/callback', export: true, to: 'sessions#create'
  #get '/login', export: true, to: 'sessions#new'

  #resources :passwords, param: :token, export: true, only: %i[new create edit update]
  constraints(id: %r{[^/]+}) do
    resources :users, export: true, only: %i[create update]
    resource :session, export: true, only: %i[create destroy]
    resources :subjects, export: true, only: %i[index show]
    resources :authors, export: true, only: %i[show]
    resources :papers, export: true, only: %i[index show]
  end

  root "subjects#show"
end
