Rails.application.routes.draw do
  get 'carts/show'
  get 'carts/add_item'
  get 'carts/remove_item'
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

  resource :cart, only: [:show] do
    post 'add_item', to: 'carts#add_item', as: 'add_to'
    delete 'remove_item', to: 'carts#remove_item', as: 'remove_from'
  end

  # Search products
  get 'search_products', to: 'products#search'

  # Filter products by category
  get 'products/category/:category', to: 'products#index', as: 'category_products'
end
