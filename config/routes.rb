# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resource :user, only: %i[create show]
      resource :sign_in, only: [:create]
      resources :categories, only: %i[index create update]
      resources :ingredients

      namespace :users do
        resources :recipe, only: %i[create update index show]
        resources :favorites, only: [:index]
      end

      namespace :adm do
        resources :users, only: %i[index create update show]
      end

      resources :recipes, only: %i[index show] do
        get :ingredients, on: :member
        resources :comments, only: %i[index create destroy]
        resource :rating, only: %i[show create]
        resource :favorite, only: %i[show create destroy]
      end
    end

    namespace :v2 do
      resources :recipes, only: [:index]
    end
  end
end
