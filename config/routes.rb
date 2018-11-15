Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resource :user, only: [:create, :show]
      resource :sign_in, only: [:create]
      resources :categories, only: [:index]

      namespace :users do
        resources :recipe, only: [:create, :update, :index, :show]
      end

      namespace :adm do
        resources :users, only: [:index, :create, :update]
      end

      resources :recipes, only: [:index, :show] do
        resources :comments, only: [:index, :create]
        resource :rating, only: [:show, :create]
      end

    end
  end

end
