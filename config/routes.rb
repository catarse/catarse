Catarse::Application.routes.draw do

  filter :locale
  
  root :to => "projects#index"

  match "/abandamaisbonitadacidade" => "projects#banda", :as => :banda


  match "/guidelines" => "projects#guidelines", :as => :guidelines
  match "/faq" => "projects#faq", :as => :faq
  match "/terms" => "projects#terms", :as => :terms
  match "/privacy" => "projects#privacy", :as => :privacy
  match "/thank_you" => "projects#thank_you", :as => :thank_you
  match "/moip" => "projects#moip", :as => :moip
  match "/explore" => "projects#explore", :as => :explore
  match "/credits" => "credits#index", :as => :credits

  post "/pre_auth" => "sessions#pre_auth", :as => :pre_auth
  get "/auth" => "sessions#auth", :as => :auth
  get "/post_auth" => "sessions#post_auth", :as => :post_auth
  match "/auth/:provider/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"
  match "/logout" => "sessions#destroy", :as => :logout
  if Rails.env == "test"
    match "/fake_login" => "sessions#fake_create", :as => :fake_login
  end
  resources :projects, :only => [:index, :new, :create, :show] do
    collection do
      get 'explore'
      get 'start'
      post 'send_mail'
      get 'guidelines'
      get 'faq'
      get 'terms'
      get 'privacy'
      get 'vimeo'
      get 'cep'
      get 'pending'
      get 'pending_backers'
      get 'thank_you'
      post 'moip'
      post 'update_attribute_on_the_spot'
      get 'banda'
    end
    member do
      get 'back'
      post 'review'
      put 'pay'
      get 'backers'
      get 'embed'
      get 'video_embed'
      get 'comments'
      get 'updates'
    end
  end
  resources :users, :only => [:show] do
    post 'update_attribute_on_the_spot', :on => :collection
  end
  resources :credits, :only => [:index] do
    collection do
      get 'buy'
      post 'refund'
    end
  end
  resources :comments, :only => [:index, :show, :create, :destroy]
  resources :sites, :only => [:show]
end
