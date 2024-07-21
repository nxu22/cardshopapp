Rails.application.routes.draw do
  root 'products#index'

  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :products, only: [:index, :show]
  resources :categories, only: [:index, :show]
  resources :charges, only: [:create]
  resources :orders, only: [:show]

  resource :cart, only: [:show, :update] do
    post 'add_item', to: 'carts#add_item', as: 'add_to'
    delete 'remove_item', to: 'carts#remove_item', as: 'remove_from'
    patch 'update', to: 'carts#update', as: 'update'
    post 'checkout', to: 'carts#checkout', as: 'checkout'
  end

  get 'search_products', to: 'products#search'

  get 'products/category/:category', to: 'products#index', as: 'category_products'

  get 'checkout/user_info', to: 'orders#user_info', as: 'user_info'
  post 'checkout/user_info', to: 'orders#save_user_info'
  patch 'checkout/user_info', to: 'orders#save_user_info'

  get 'checkout/order_details', to: 'orders#order_details', as: 'order_details'
  post 'checkout/order_details', to: 'orders#save_order_details'

  get 'checkout/payment_info', to: 'orders#payment_info', as: 'payment_info'
  post 'checkout/payment_info', to: 'orders#process_payment'
end
