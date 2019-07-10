# frozen_string_literal: true

class Blacklist
  def matches?(request)
    !BannedIp.exists? ip: request.remote_ip
  end
end

Catarse::Application.routes.draw do
  constraints Blacklist.new do
    mount RedactorRails::Engine => '/redactor_rails'
    mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
    devise_for(
      :users,
      {
        path: '',
        path_names:   { sign_in: :login, sign_out: :logout, sign_up: :sign_up },
        controllers:  { omniauth_callbacks: :omniauth_callbacks, passwords: :passwords, sessions: :sessions }
      }
    )

    devise_scope :user do
      post '/sign_up', { to: 'devise/registrations#create', as: :sign_up }
      get '/not-my-account', to: 'sessions#destroy_and_redirect', as: :not_my_account
    end

    # User permalink profile
    constraints SubdomainConstraint do
      get '/', to: 'users#show'
    end

    get '/amigos' => redirect('http://crowdfunding.catarse.me/amigos')
    get '/criadores' => redirect('http://crowdfunding.catarse.me/criadores')
    get '/paratodos' => redirect('http://crowdfunding.catarse.me/paratodos')

    get '/support_forum' => 'zendesk_sessions#create', as: :zendesk_session_create
    get '/posts' => 'application#get_blog_posts'
    get '/project_edit' => 'application#redirect_to_last_edit'
    get '/billing_edit' => 'application#redirect_to_user_billing'
    get '/user_contributions' => 'application#redirect_to_user_contributions'
    post '/subscribe_newsletter' => 'mail_marketing_users#subscribe'
    get '/unsubscribe_list' => 'mail_marketing_users#unsubscribe'

    get '/thank_you' => 'static#thank_you'
    get '/follow-fb-friends' => 'users#follow_fb_friends', as: :follow_fb_friends
    get '/connect-facebook' => 'application#connect_facebook', as: :connect_fb

    get '/notifications/:notification_type/:notification_id' => 'notifications#show'

    filter :locale, exclude: /\/auth\//

    mount CatarsePagarme::Engine => '/', as: :catarse_pagarme
    # mount CatarseWepay::Engine => "/", as: :catarse_wepay
    mount Dbhero::Engine => '/dbhero', as: :dbhero

    resources :categories, only: [] do
      member do
        get :subscribe, to: 'categories/subscriptions#create'
        get :unsubscribe, to: 'categories/subscriptions#destroy'
      end
    end
    resources :auto_complete_projects, only: [:index]
    resources :auto_complete_cities, only: [:index]
    resources :rewards, only: [] do
      resources :surveys, only: [:create, :update], controller: 'surveys'
    end
    resources :projects, path: '/', only: [:index]
    resources :flexible_projects, path: '/', controller: 'projects', only: [:index]
    # @TODO update links, we don't need this anymore
    resources :flexible_projects, controller: 'projects', except: [:index] do
      member do
        get :publish
        get :push_to_online
        get :validate_publish
        get :finish
      end
    end
    resources :contributions, only: [] do
      resources :surveys, only: [:show], controller: 'surveys' do
        member do
          put :answer
        end
      end
    end
    resources :projects, only: %i[create update edit new show] do
      get 'subscriptions/:any', to: 'projects#show', on: :member
      resources :accounts, only: %i[create update]
      resources :posts, controller: 'projects/posts', only: %i[destroy show create]
      resources :goals
      resources :rewards do
        member do
          get :toggle_survey_finish
          post :upload_image
          delete :delete_image
        end
        resources :surveys, only: [:new], controller: 'surveys'
        post :sort, on: :member
      end
      get 'debit_note/:fiscal_date', to: 'projects/project_fiscal_data#debit_note'
      get 'inform/:fiscal_year', to: 'projects/project_fiscal_data#inform'
#      resources :debit_note,  { only: [:show], controller: 'projects/project_fiscal_data', action: 'debit_note' } do
#        get '/:fiscal_date', to: 'projects/project_fiscal_data#debit_note'
#      end
#      resources :inform,  { only: [:show], controller: 'projects/project_fiscal_data', action: 'inform' }
      resources :contributions, { except: [:index], controller: 'projects/contributions' } do
        collection do
          get :fallback_create, to: 'projects/contributions#create'
          put :update_status
        end
        member do
          get 'toggle_anonymous'
          get 'toggle_delivery'
          get :second_slip
          get :receipt
        end
        put :credits_checkout, on: :member
      end

      collection do
        get :fallback_create, to: 'projects#create'
      end
      get 'video', on: :collection
      member do
        post :upload_image
        get 'insights'
        get 'posts'
        get 'surveys'
        get 'fiscal'
        get 'contributions_report'
        get 'subscriptions_report'
        get 'subscriptions_report_download'
        get 'subscriptions_report_for_project_owners'
        get 'subscriptions_monthly_report_for_project_owners'
        get 'download_reports'
        put 'pay'
        get 'embed'
        get 'video_embed'
        get 'embed_panel'
        get 'send_to_analysis'
        get 'publish'
        get 'validate_publish'
        get 'push_to_online'
      end
    end
    resources :users do
      resources :credit_cards, controller: 'users/credit_cards', only: [:destroy]
      member do
        # get :balance
        post :upload_image
        get :credit_cards
        get :unsubscribe_notifications
        get :credits
        get :settings
        get :billing
        get :reactivate
        post :new_password
        post :ban
      end

      resources :unsubscribes, only: [:create]
      member do
        get 'projects'
        put 'unsubscribe_update'
        put 'update_email'
        put 'update_password'
      end
    end

    get '/terms-of-use' => redirect('https://crowdfunding.catarse.me/legal/termos-de-uso')
    get '/privacy-policy' => redirect('https://crowdfunding.catarse.me/legal/politica-de-privacidade')
    get '/start' => redirect('https://crowdfunding.catarse.me/comece')
    get '/start-sub' => redirect('https://crowdfunding.catarse.me/comece')
    get '/jobs' => 'high_voltage/pages#show', id: 'jobs'
    get '/hello' => redirect('/start')
    get '/press' => redirect('https://crowdfunding.catarse.me/imprensa')
    get '/assets' => redirect('https://crowdfunding.catarse.me/assets')
    get '/guides' => redirect('http://fazum.catarse.me/guia-financiamento-coletivo')
    get '/new-admin' => 'high_voltage/pages#show', id: 'new_admin'
    get '/explore' => 'high_voltage/pages#show', id: 'explore'
    get '/team' => redirect('https://crowdfunding.catarse.me/nosso-time')
    get '/about' => redirect('https://crowdfunding.catarse.me/quem-somos')
    get '/flex' => redirect('http://crowdfunding.catarse.me')
    get '/projects_dashboard' => 'high_voltage/pages#show', id: 'projects_dashboard'

    # Root path should be after channel constraints
    root to: 'projects#index'

    namespace :reports do
      resources :contribution_reports_for_project_owners, only: [:index]
    end

    # Feedback form
    resources :feedbacks, only: [:create]

    namespace :admin do
      resources :balance_transfers do
        collection do
          post 'batch_approve'
          post 'batch_manual'
          post 'batch_reject'
          #post 'process_transfers'
        end
      end

      resources :projects, :flexible_projects, controller: 'projects', only: %i[index update destroy] do
        member do
          put :revert_or_finish
          put 'approve'
          put 'push_to_online'
          put 'reject'
          put 'push_to_draft'
          put 'push_to_trash'
        end
      end

      resources :financials, only: [:index]

      resources :subscription_payments do
        collection do
          post :batch_chargeback
        end
      end

      resources :contributions, only: [] do
        member do
          put 'gateway_refund'
        end
        collection do
          post 'batch_chargeback'
        end
      end

      namespace :reports do
        resources :contribution_reports, only: [:index]
      end
    end

    resource :api_token, only: [:show] do
      collection do
        get :common
        get :common_proxy
      end
    end

    get '/:permalink' => 'projects#show', as: :project_by_slug
  end
end

