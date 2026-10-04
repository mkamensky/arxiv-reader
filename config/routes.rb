Rails.application.routes.draw do
  get 'auth/:provider/callback', export: true, to: 'sessions#omni'
  #get '/login', export: true, to: 'sessions#new'

  #resources :passwords, param: :token, export: true, only: %i[new create edit update]
  resources :subjects, export: true, only: %i[show], defaults: { id: :math }
  constraints(id: %r{[a-zA-Z0-9._/-]+}) do
    resources :users, export: true, only: %i[create show update]
    resource :recommendations, export: true, only: %i[show create]
    get 'recommendations/sidebar', to: 'recommendations#sidebar', as: :recommendations_sidebar
    get 'papers/:paper_id/recommendation_assessment',
        to: 'recommendations#assessment', as: :paper_recommendation_assessment
    post 'papers/:paper_id/recommendation_feedback',
         to: 'recommendation_feedbacks#create', as: :paper_recommendation_feedback
    post 'recommendations/:recommendation_id/second_opinions',
         to: 'second_opinions#create', as: :recommendation_second_opinions
    resources :tags, export: true, only: %i[show create update destroy]
    resource :session, export: true, only: %i[create destroy]
    resources :authors, export: true, only: %i[index show]
    resources :papers, export: true, only: %i[index show]
  end

  root "subjects#show"

  mount SolidErrors::Engine, at: "/solid_errors" unless Rails.env.local?
end
