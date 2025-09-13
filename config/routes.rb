require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  post 'cart', to: 'carts#create'
  post 'cart/add_item', to: 'carts#add_item'
  delete 'cart/:product_id', to: 'carts#remove_product'
  get 'cart',  to: 'carts#list_cart'

  root "rails/health#show"
end
