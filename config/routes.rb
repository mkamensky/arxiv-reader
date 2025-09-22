Rails.application.routes.draw do
  constraints(id: %r{[^/]+}) do
    devise_for :users, skip: %i[sessions passwords registrations]
    as :user do
      get 'login', to: 'users/sessions#new', as: :new_user_session
      post 'login', to: 'users/sessions#create', as: :user_session
      match 'logout', to: 'users/sessions#destroy', as: :destroy_user_session, via: Devise.mappings[:user].sign_out_via
    end
    resources :subjects, export: true
    resources :authors, export: true
    resources :papers, export: true
    resources :categories, export: true
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "subjects#show"
end
