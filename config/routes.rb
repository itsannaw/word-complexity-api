# frozen_string_literal: true

Rails.application.routes.draw do
  post '/complexity-score', to: 'api/v1/complexity_scores#create'
  get '/complexity-score/:job_id', to: 'api/v1/complexity_scores#show'

  # Health check endpoint
  get '/health', to: 'health#check'

  # Swagger documentation
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
end
