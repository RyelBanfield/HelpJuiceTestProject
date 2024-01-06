# frozen_string_literal: true

Rails.application.routes.draw do
  root 'searches#index'

  get '/searches/suggestions', to: 'searches#suggestions'
  post '/searches', to: 'searches#create'

  resources :searches, only: %i[index create]
end
