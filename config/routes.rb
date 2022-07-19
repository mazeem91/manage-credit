# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :accounts
      post "accounts/:id/transfer_by_phone_number", to: "accounts#transfer_by_phone_number"
      post "accounts/:id/transfer_by_email", to: "accounts#transfer_by_email"
    end
  end
end
