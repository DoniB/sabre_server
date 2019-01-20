# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resource :user, only: [:create, :show]
      resource :sign_in, only: [:create]
      resources :categories, only: [:index]
      resources :ingredients

      namespace :users do
        resources :recipe, only: [:create, :update, :index, :show]
        resources :favorites, only: [:index]
      end

      namespace :adm do
        resources :users, only: [:index, :create, :update, :show]
      end

      resources :recipes, only: [:index, :show] do
        resources :comments, only: [:index, :create, :destroy]
        resource :rating, only: [:show, :create]
        resource :favorite, only: [:show, :create, :destroy]
      end
    end
  end
end
