# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: [:create]

  resource :user, only: [:destroy]

  resources :todos do
    member do
      put 'complete'
      put 'incomplete'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
