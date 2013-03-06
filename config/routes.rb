require 'sidekiq/web'

Catarse::Application.routes.draw do


  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  check_user_admin = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin }

  filter :locale, exclude: /\/auth\//

  # Mountable engines
  constraints check_user_admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount CatarsePaypalExpress::Engine  => "/", :as => :catarse_paypal_express
  mount CatarseMoip::Engine           => "/", :as => :catarse_moip


  # Non production routes
  if Rails.env.development?
    resources :emails, :only => [ :index ]
  end


  # Static Pages
  get '/sitemap',               to: 'static#sitemap',             as: :sitemap
  get '/guidelines',            to: 'static#guidelines',          as: :guidelines 
  get "/guidelines_tips",       to: "static#guidelines_tips",     as: :guidelines_tips
  get "/guidelines_backers",    to: "static#guidelines_backers",  as: :guidelines_backers
  get "/guidelines_start",      to: "static#guidelines_start",    as: :guidelines_start
  get "/about",                 to: "static#about",               as: :about
  get "/faq",                   to: "static#faq",                 as: :faq


  match "/explore" => "explore#index", :as => :explore
  match "/explore#:quick" => "explore#index", :as => :explore_quick
  match "/credits" => "credits#index", :as => :credits

  match "/reward/:id" => "rewards#show", :as => :reward
  resources :posts, only: [:index, :create]

  namespace :reports do
    resources :backer_reports_for_project_owners, only: [:index]
  end

  resources :projects do
    resources :updates, only: [ :index, :create, :destroy ]
    resources :rewards, only: [ :index, :create, :update, :destroy ]
    resources :backers, controller: 'projects/backers', only: [ :index, :show, :new, :create ] do
      member do
        match 'credits_checkout'
        post 'update_info'
      end
    end
    collection do
      get 'vimeo'
      get 'check_slug'
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
    collection do
      get 'set_email'
    end
    member do
      get 'projects'
      get 'credits'
      put 'unsubscribe_update'
      put 'update_email'
    end
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

    resources :backers, only: [ :index, :update ] do
      member do
        put 'confirm'
        put 'unconfirm'
        put 'change_reward'
      end
    end
    resources :users, only: [ :index ]

    namespace :reports do
      resources :backer_reports, only: [ :index ]
    end
  end

  match "/:permalink" => "projects#show", as: :project_by_slug

  # Channels
  namespace :channels do
    match '/:permalink', to: 'profiles#show', as: :profile
  end



  # Root path
  root to: 'projects#index'

end
