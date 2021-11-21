Rails.application.routes.draw do

  resources :banks
  get '/orders/status/:id' => 'orders#status'
  resources :orders do
    collection do
  		post :checkout
  		get :payment
      get :place
      get :fiapt
      get :fipo
    end
  end
  root to: 'visitors#index'
  devise_for :users, controllers: {
    registrations:  'users/registrations',
    sessions:       'users/sessions',
    passwords:      'users/passwords',
  }
  resources :users
end
