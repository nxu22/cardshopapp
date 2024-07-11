Rails.application.routes.draw do
  get 'categories/index'
  get 'categories/show'
  get 'products/index'
  get 'products/show'
  root 'products#index'
  resources :products, only: [:index, :show]
  resources :categories, only: [:index, :show]
end
