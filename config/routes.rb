require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  post 'cart', to: 'carts#create'
  post 'cart/add_items', to: 'carts#add_item'
  delete 'cart/:product_id', to: 'carts#remove_product'
  get 'cart',  to: 'carts#show'

  root "rails/health#show"
end
