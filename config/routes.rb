Rails.application.routes.draw do
  resources :users, only: :create

  resources :todos do
    member do
      put 'complete'
      put 'uncomplete'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
