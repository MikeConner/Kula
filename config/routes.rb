Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root :to => 'static_pages#home'

  resources :payments, :except => [:new, :create]
  resources :batches, :except => [:edit, :update] do
    get 'export', :on => :member
  end
  
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
  
  resources :delayed_rakes, :only => [:index] do
    collection do
      post 'replicate'
      post 'close_year'
      post 'generate_payment_batch'
    end
  end
  
  resources :global_settings, :only => [:edit, :update]
  
  # Static pages
  get "/site_admin" => "static_pages#admin_index"
end
