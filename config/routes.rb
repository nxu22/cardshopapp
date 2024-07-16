Rails.application.routes.draw do
  get 'orders/new'
  get 'orders/create'
  get 'orders/show'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'products#index'

  # User routes for signup and account creation
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'

  # Session routes for login and logout
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Resource routes for products and categories
  resources :products, only: [:index, :show]
  resources :categories, only: [:index, :show]

  # Cart routes with nested routes for adding and removing items
  resource :cart, only: [:show, :update] do
    post 'add_item', to: 'carts#add_item', as: 'add_to'
    delete 'remove_item', to: 'carts#remove_item', as: 'remove_from'
    patch 'update', to: 'carts#update', as: 'update' # Adding this line
  end

  # Search products
  get 'search_products', to: 'products#search'

  # Filter products by category
  get 'products/category/:category', to: 'products#index', as: 'category_products'

  # Checkout routes
  get 'checkout', to: 'orders#new'
  post 'checkout', to: 'orders#create'

  resources :orders, only: [:show]
end
