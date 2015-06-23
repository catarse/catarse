Catarse::Application.routes.draw do
  mount RedactorRails::Engine => '/redactor_rails'
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for(
    :users,
    {
      path: '',
      path_names:   { sign_in: :login, sign_out: :logout, sign_up: :sign_up },
      controllers:  { omniauth_callbacks: :omniauth_callbacks, passwords: :passwords }
    }
  )

  devise_scope :user do
    post '/sign_up', {to: 'devise/registrations#create', as: :sign_up}
  end

  get '/thank_you' => "static#thank_you"

  filter :locale, exclude: /\/auth\//

  mount CatarseMoip::Engine => "/", as: :catarse_moip
  mount CatarsePagarme::Engine => "/", as: :catarse_pagarme
  mount CatarseApi::Engine => "/api", as: :catarse_api
 #mount CatarseWepay::Engine => "/", as: :catarse_wepay
  mount Dbhero::Engine => "/dbhero", as: :dbhero

  resources :bank_accounts, except: [:destroy, :index] do
    member do
      get 'confirm'
      put 'request_refund'
    end
  end

  resources :categories, only: [] do
    member do
      get :subscribe, to: 'categories/subscriptions#create'
      get :unsubscribe, to: 'categories/subscriptions#destroy'
    end
  end
  resources :auto_complete_projects, only: [:index]
  resources :projects, only: [:index, :create, :update, :edit, :new, :show] do
    resources :metrics, only: [:index], controller: "projects/metrics"
    resources :accounts, only: [:create, :update]
    resources :posts, controller: 'projects/posts', only: [ :index, :destroy ]
    resources :rewards, only: [ :index ] do
      post :sort, on: :member
    end
    resources :contributions, {except: [:index], controller: 'projects/contributions'} do
      collection do
        get :details, to: 'projects/contribution_details#index'
        get :fallback_create, to: 'projects/contributions#create'
      end
      put :credits_checkout, on: :member
    end

    get 'video', on: :collection
    member do
      get :reminder, to: 'projects/reminders#create'
      delete :reminder, to: 'projects/reminders#destroy'
      put 'pay'
      get 'embed'
      get 'video_embed'
      get 'about_mobile'
      get 'embed_panel'
      get 'send_to_analysis'
      get 'publish'
    end
  end
  resources :users do
    resources :credit_cards, controller: 'users/credit_cards', only: [ :destroy ]
    member do
      get :unsubscribe_notifications
      get :credits
      get :settings
      get :billing
      get :reactivate
    end

    resources :unsubscribes, only: [:create]
    member do
      get 'projects'
      put 'unsubscribe_update'
      put 'update_email'
      put 'update_password'
    end
  end

  get "/terms-of-use" => 'high_voltage/pages#show', id: 'terms_of_use'
  get "/privacy-policy" => 'high_voltage/pages#show', id: 'privacy_policy'
  get "/start" => 'high_voltage/pages#show', id: 'start'
  get "/jobs" => 'high_voltage/pages#show', id: 'jobs'
  get "/hello" => 'high_voltage/pages#show', id: 'hello'
  get "/press" => 'high_voltage/pages#show', id: 'press'
  get "/assets" => 'high_voltage/pages#show', id: 'assets'
  get "/guides" => 'high_voltage/pages#show', id: 'guides', as: :guides



  # User permalink profile
  constraints SubdomainConstraint do
    get "/", to: 'users#show'
  end

  # Root path should be after channel constraints
  root to: 'projects#index'

  get "/explore" => "explore#index", as: :explore

  namespace :reports do
    resources :contribution_reports_for_project_owners, only: [:index]
  end

  # Feedback form
  resources :feedbacks, only: [:create]

  namespace :admin do
    resources :projects, only: [ :index, :update, :destroy ] do
      member do
        put 'approve'
        put 'push_to_online'
        put 'reject'
        put 'push_to_draft'
        put 'push_to_trash'
      end
    end

    resources :financials, only: [ :index ]

    resources :contributions, only: [ :index, :update, :show ] do
      member do
        get :second_slip
        put 'pay'
        put 'change_reward'
        put 'refund'
        put 'trash'
        put 'gateway_refund'
      end
    end
    resources :users, only: [ :index ]

    namespace :reports do
      resources :contribution_reports, only: [ :index ]
    end
  end

  resource :api_token, only: [:show]

  get "/:permalink" => "projects#show", as: :project_by_slug

end
