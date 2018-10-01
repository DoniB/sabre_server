Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resource :user, only: [:create]
      resource :sign_in, only: [:create]

      namespace :users do
        resources :recipe, only: [:create]
      end
    end
  end

end
