Rails.application.routes.draw do

  resources :banks
  get '/orders/status/:id' => 'orders#status'
  resources :orders do
    collection do
  		post :checkout
  		get :payment
    end
  end
  root to: 'visitors#index'
  devise_for :users
  resources :users
end
