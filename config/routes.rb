Catarse::Application.routes.draw do
  
  # TODO change back the root to "projects#index" when we launch
  if Rails.env == "production"
    root :to => "projects#teaser"
  else
    root :to => "projects#index"
  end
  
  post "/auth" => "sessions#auth", :as => :auth
  match "/auth/:provider/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"
  match "/logout" => "sessions#destroy", :as => :logout
  if Rails.env == "test"
    match "/fake_login" => "sessions#fake_create", :as => :fake_login
  end
  resources :projects, :only => [:index, :new, :create, :show] do
    collection do
      get 'teaser'
      get 'guidelines'
      get 'vimeo'
      get 'pending'
      get 'pending_backers'
      post 'update_attribute_on_the_spot'
    end
    member do
      get 'back'
      post 'review'
      get 'thank_you'
      get 'backers'
      get 'embed'
      get 'video_embed'
    end
  end
  resources :users, :only => [:show] do
    post :update_attribute_on_the_spot, :on => :collection
  end
end
