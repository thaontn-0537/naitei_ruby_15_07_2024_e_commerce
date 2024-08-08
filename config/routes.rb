Rails.application.routes.draw do
  scope "(:locale)", locale: /vi|en/ do
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    root "static_pages#index"
    get "static_pages/index"
    get "ajax_products", to: "static_pages#load_products"
    get "/cart", to: "carts#index"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    resources :users, only: %i(new create show)
  end
end
