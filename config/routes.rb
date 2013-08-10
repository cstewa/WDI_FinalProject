RailsProject::Application.routes.draw do
  post "images/new" => 'images#new', :as => "new_image"

  match "oauth/callback" => "oauths#callback"
  match "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  root :to => 'static_pages#index'

  resources :sessions, only:[:new, :create, :destroy]
  resources :users

  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout


  get "profile/:id" => 'users#show', :as => "profile"

  get "follow/:id" => 'users#add_follower', :as => "follow"

  post '/search' => 'images#search', as: :search
end
