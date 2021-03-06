Rails.application.routes.draw do
  root 'pages#home'
  devise_for :admins
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  
  devise_for :customers, controllers: { registrations: 'customers/registrations', 
                                        sessions: 'customers/sessions',
                                        passwords: 'customers/passwords', 
                                        omniauth_callbacks: "customers/omniauth_callbacks" }
  devise_scope :customer do
    get '/settings', to: 'customers#settings'
    put '/change_password', to: 'customers#change_password'
    put '/change_personal_info', to: 'customers#change_personal_info'
  end
  
  resources :orders, only: [:index, :show, :new, :update, :destroy] do
    put "/add_to_order", to: "orders#add_to_order", on: :collection 
    get '/checkout_address', to: 'orders#checkout_address', on: :collection 
    post '/set_address', to: 'orders#set_address', on: :collection 
    get '/checkout_delivery', to: 'orders#checkout_delivery', on: :collection 
    put '/set_delivery', to: 'orders#set_delivery', on: :collection 
    get '/checkout_payment', to: 'orders#checkout_payment', on: :collection 
    get '/checkout_confirm', to: 'orders#checkout_confirm', on: :collection 
    get '/checkout_complete', to: 'orders#checkout_complete', on: :collection 
  end 
  
  resources :order_items, only: [:destroy] 
  resources :credit_cards, only: [:create, :update] 
  resources :addresses, only: [:update, :create]  
  resources :books, only: [:show, :index] do 
    resources :ratings, only: [:new, :create]
  end
  resources :categories, only: [:show]
end
