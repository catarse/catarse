require 'sidekiq/web'

Catarse::Application.routes.draw do

  devise_for :users, path: '',
    path_names:   { sign_in: :login, sign_out: :logout, sign_up: :sign_up },
    controllers:  { omniauth_callbacks: :omniauth_callbacks, passwords: :passwords }


  devise_scope :user do
    post '/sign_up', to: 'devise/registrations#create', as: :sign_up
  end


  get '/thank_you' => "static#thank_you"


  check_user_admin = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin }

  filter :locale, exclude: /\/auth\//

  # Mountable engines
  constraints check_user_admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount CatarsePaypalExpress::Engine => "/", as: :catarse_paypal_express
  mount CatarseMoip::Engine => "/", as: :catarse_moip
#  mount CatarseWepay::Engine => "/", as: :catarse_wepay

  # Channels
  constraints subdomain: /^(?!www|secure|test|local)(\w+)/ do
    namespace :channels, path: '' do
      namespace :admin do
        namespace :reports do
          resources :subscriber_reports, only: [ :index ]
        end
        resources :posts
        resources :followers, only: [ :index ]
        resources :projects, only: [ :index, :update] do
          member do
            put 'approve'
            put 'reject'
            put 'push_to_draft'
            put 'push_to_trash'
          end
        end
      end

      resources :posts
      get '/', to: 'profiles#show', as: :profile
      get '/how-it-works', to: 'profiles#how_it_works', as: :about
      resource :profile
      resources :projects, only: [:new, :create, :show] do
        collection do
          get 'video'
        end
      end
      # NOTE We use index instead of create to subscribe comming back from auth via GET
      resource :channels_subscriber, only: [:show, :destroy], as: :subscriber
    end
  end

  # Root path should be after channel constraints
  root to: 'projects#index'

  get "/explore" => "explore#index", as: :explore

  namespace :reports do
    resources :contribution_reports_for_project_owners, only: [:index]
  end

  resources :projects, only: [:index, :create, :update, :new, :show] do
    resources :updates, controller: 'projects/updates', only: [ :index, :create, :destroy ]
    resources :rewards, only: [ :index, :create, :update, :destroy, :new, :edit ] do
      member do
        post 'sort'
      end
    end
    resources :contributions, controller: 'projects/contributions' do
      member do
        put 'credits_checkout'
      end
    end
    collection do
      get 'video'
    end
    member do
      put 'pay'
      get 'embed'
      get 'video_embed'
      get 'embed_panel'
      get 'send_to_analysis'
    end
  end
  resources :users do
    resources :projects, controller: 'users/projects', only: [ :index ]
    member do
      get :unsubscribe_notifications
      get :credits
    end
    collection do
      get :uservoice_gadget
    end
    resources :contributions, controller: 'users/contributions', only: [:index] do
      member do
        get :request_refund
      end
    end

    resources :unsubscribes, only: [:create]
    member do
      get 'projects'
      put 'unsubscribe_update'
      put 'update_email'
      put 'update_password'
    end
  end

  namespace :admin do
    resources :projects, only: [ :index, :update, :destroy ] do
      member do
        put 'approve'
        put 'reject'
        put 'push_to_draft'
        put 'push_to_trash'
      end
    end

    resources :statistics, only: [ :index ]
    resources :financials, only: [ :index ]

    resources :contributions, only: [ :index, :update, :show ] do
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
      resources :contribution_reports, only: [ :index ]
    end
  end

  get "/:permalink" => "projects#show", as: :project_by_slug
end
