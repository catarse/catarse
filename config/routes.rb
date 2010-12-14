Catarse::Application.routes.draw do
  root :to => "projects#index"
  post "/auth" => "sessions#auth", :as => :auth
  match "/auth/:provider/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"
  match "/logout" => "sessions#destroy", :as => :logout
  if Rails.env == "test"
    match "/fake_login" => "sessions#fake_create", :as => :fake_login
  end
  resources :projects, :only => [:index, :new, :create, :show, :edit, :update] do
    get 'guidelines', :on => :collection
    get 'vimeo', :on => :collection
    get 'back', :on => :member
  end
  resources :users, :only => [:show]
end
