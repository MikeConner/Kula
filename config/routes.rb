Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root :to => 'static_pages#home'

  resources :payments, :only => [:index]
  resources :batches, :only => [:new, :create]
  resources :partners, :only => [:index, :edit, :update]
  resources :causes, :only => [:index, :show]
  
  # Static pages
  get "/site_admin" => "static_pages#admin_index"
end
