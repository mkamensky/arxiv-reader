Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  constraints(id: %r{[^/]+}) do
    resources :subjects, export: true
    resources :authors, export: true
    resources :papers, export: true
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "subjects#show"
end
