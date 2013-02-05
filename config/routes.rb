require 'sidekiq/web'

Catarse::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "registrations", :passwords => "passwords"} do
    get "/login" => "devise/sessions#new"
  end

  check_user_admin = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin }
  constraints check_user_admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  # Non production routes
  if Rails.env == "test"
    match "/fake_login" => "sessions#fake_create", :as => :fake_login
  elsif Rails.env == "development"
    resources :emails, :only => [ :index ]
  end

  mount CatarsePaypalExpress::Engine => "/", :as => "catarse_paypal_express"
  mount CatarseMoip::Engine => "/", :as => "catarse_moip"

  filter :locale

  root to: 'projects#index'

  # Static Pages
  match '/sitemap' => "static#sitemap", :as => :sitemap
  match "/guidelines" => "static#guidelines", :as => :guidelines
  match "/guidelines_tips" => "static#guidelines_tips", :as => :guidelines_tips
  match "/guidelines_backers" => "static#guidelines_backers", :as => :guidelines_backers
  match "/guidelines_start" => "static#guidelines_start", :as => :guidelines_start
  match "/about" => "static#about", :as => :about
  match "/faq" => "static#faq", :as => :faq
  match "/terms" => "static#terms", :as => :terms
  match "/privacy" => "static#privacy", :as => :privacy

  match "/explore" => "explore#index", :as => :explore
  match "/explore#:quick" => "explore#index", :as => :explore_quick
  match "/credits" => "credits#index", :as => :credits

  post "/auth" => "sessions#auth", :as => :auth
  match "/auth/:provider/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"
  match "/logout" => "sessions#destroy", :as => :logout
  match "/reward/:id" => "rewards#show", :as => :reward
  resources :posts, only: [:index, :create]

  namespace :reports do
    resources :backer_reports_for_project_owners, only: [:index]
  end

  resources :projects do
    resources :updates, only: [ :index, :create, :destroy ]
    resources :rewards, only: [ :index, :create, :update, :destroy ]
    resources :backers, controller: 'projects/backers', only: [ :index, :new ] do
      collection do
        post 'review'
      end
      member do
        match 'credits_checkout'
        post 'update_info'
        get 'thank_you'
      end
    end
    collection do
      get 'start'
      post 'send_mail'
      get 'vimeo'
      get 'check_slug'
      post 'update_attribute_on_the_spot'
    end
    member do
      put 'pay'
      get 'embed'
      get 'video_embed'
    end
  end
  resources :users do
    resources :backers, :only => [:index]
    resources :unsubscribes, :only => [:create]
    member do
      get 'projects'
      get 'credits'
      put 'unsubscribe_update'
    end
    post 'update_attribute_on_the_spot', :on => :collection
  end
  match "/users/:id/request_refund/:back_id" => 'users#request_refund'

  resources :credits, only: [:index] do
    collection do
      get 'buy'
      post 'refund'
    end
  end

  namespace :adm do
    resources :projects, only: [ :index, :update ] do
      member do
        put 'approve'
        put 'reject'
        put 'push_to_draft'
      end
    end

    resources :financials, only: [ :index ]

    resources :backers, only: [ :index ] do
      member do
        put 'confirm'
        put 'unconfirm'
      end
      collection do
        post 'update_attribute_on_the_spot'
      end
    end
    resources :users, only: [ :index ]

    namespace :reports do
      resources :backer_reports, only: [ :index ]
    end
  end

  match "/:permalink" => "projects#show", as: :project_by_slug
end
