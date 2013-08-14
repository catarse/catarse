require 'sidekiq/web'

Catarse::Application.routes.draw do

  devise_for :users, path: '',
    path_names:   { sign_in: :login, sign_out: :logout, sign_up: :sign_up }, 
    controllers:  { omniauth_callbacks: :omniauth_callbacks }

  devise_scope :user do
    post '/sign_up', to: 'devise/registrations#create', as: :sign_up
  end

  # Root path
  root to: 'projects#index'

  match '/thank_you' => "static#thank_you"

  check_user_admin = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin }

  filter :locale, exclude: /\/auth\//

  # Mountable engines
  constraints check_user_admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount CatarsePaypalExpress::Engine => "/", as: :catarse_paypal_express
  mount CatarseMoip::Engine => "/", as: :catarse_moip

  # Non production routes
  if Rails.env.development?
    resources :emails, only: [ :index ]
  end

  # Channels
  constraints subdomain: 'asas' do
    namespace :channels, path: '' do
      namespace :adm do
        resources :projects, only: [ :index, :update] do
          member do
            put 'approve'
            put 'reject'
            put 'push_to_draft'
          end
        end
      end
      get '/', to: 'profiles#show', as: :profile
      get '/how-it-works', to: 'profiles#how_it_works', as: :about
      resources :projects, only: [:new, :create, :show] do
        collection do
          get 'video'
          get 'check_slug'
        end
      end
      resources :channels_subscribers, only: [:index, :create, :destroy]
    end
  end

  # Static Pages
  get '/sitemap',               to: 'static#sitemap',             as: :sitemap
  get '/guidelines',            to: 'static#guidelines',          as: :guidelines
  get "/guidelines_tips",       to: "static#guidelines_tips",     as: :guidelines_tips
  get "/guidelines_backers",    to: "static#guidelines_backers",  as: :guidelines_backers
  get "/guidelines_start",      to: "static#guidelines_start",    as: :guidelines_start
  get "/about",                 to: "static#about",               as: :about


  match "/explore" => "explore#index", as: :explore
  match "/explore#:quick" => "explore#index", as: :explore_quick
  match "/credits" => "credits#index", as: :credits

  match "/reward/:id" => "rewards#show", as: :reward
  resources :posts, only: [:index, :create]

  namespace :reports do
    resources :backer_reports_for_project_owners, only: [:index]
  end

  resources :projects do
    resources :updates, controller: 'projects/updates', only: [ :index, :create, :destroy ]
    resources :rewards, only: [ :index, :create, :update, :destroy, :new, :edit ] do
      member do
        post 'sort'
      end
    end
    resources :backers, controller: 'projects/backers', only: [ :index, :show, :new, :create ] do
      member do
        match 'credits_checkout'
        post 'update_info'
      end
    end
    collection do
      get 'video'
      get 'check_slug'
    end
    member do
      put 'pay'
      get 'embed'
      get 'video_embed'
      get 'embed_panel'
    end
  end
  resources :users do
    resources :projects, controller: 'users/projects', only: [ :index ]
    collection do
      get :uservoice_gadget
    end
    resources :backers, controller: 'users/backers', only: [:index] do
      member do
        match :request_refund
      end
    end

    resources :unsubscribes, only: [:create]
    member do
      get 'projects'
      get 'credits'
      put 'unsubscribe_update'
      put 'update_email'
      put 'update_password'
    end
  end
  # match "/users/:id/request_refund/:back_id" => 'users#request_refund'

  resources :credits, only: [:index] do
    collection do
      get 'buy'
      post 'refund'
    end
  end

  namespace :adm do
    resources :projects, only: [ :index, :update, :destroy ] do
      member do
        put 'approve'
        put 'reject'
        put 'push_to_draft'
      end
    end

    resources :statistics, only: [ :index ]
    resources :financials, only: [ :index ]

    resources :backers, only: [ :index, :update ] do
      member do
        put 'confirm'
        put 'pendent'
        put 'change_reward'
        put 'refund'
        put 'hide'
        put 'cancel'
        put 'push_to_trash'
      end
    end
    resources :users, only: [ :index ]

    namespace :reports do
      resources :backer_reports, only: [ :index ]
    end
  end

  match "/mudancadelogin" => "users#set_email", as: :set_email_users
  match "/:permalink" => "projects#show", as: :project_by_slug

end
