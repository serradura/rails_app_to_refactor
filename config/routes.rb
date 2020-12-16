Rails.application.routes.draw do
  namespace :users do
    resources :registrations, only: :create
  end

  resources :todos do
    member do
      put 'complete'
      put 'uncomplete'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
