Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root :to => 'static_pages#home'

  resources :payments, :only => [:index]
  resources :batches, :only => [:index, :show, :new, :create, :destroy]
  resources :partners, :only => [:index, :edit, :update] do
    member do
      get 'debt'
      get 'fees'
      post 'make_batch'
    end
  end
  
  resources :causes, :only => [:index, :show] do
    get 'autocomplete', :on => :collection
  end
  
  resources :adjustments, :only => [:new, :create]
  resources :users, :except => [:create]
  
  resources :cause_transactions, :only => [] do
    post 'import', :on => :collection
  end
  
  resources :delayed_rakes, :only => [:index]
  
  # Static pages
  get "/site_admin" => "static_pages#admin_index"
end
