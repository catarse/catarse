Catarse::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "registrations", :passwords => "passwords"} do
    get "/login" => "devise/sessions#new"
  end

  # Non production routes
  if Rails.env == "test"
    match "/fake_login" => "sessions#fake_create", :as => :fake_login
  elsif Rails.env == "development"
    resources :emails, :only => [ :index ]
  end

  ActiveAdmin.routes(self)

  mount CatarsePaypalExpress::Engine => "/", :as => "catarse_paypal_express"
  mount CatarseMoip::Engine => "/", :as => "catarse_moip"

  filter :locale

  root to: 'projects#index'

  match "/reports/financial/:project_id/backers" => "reports#financial_by_project", :as => :backers_financial_report
  match "/reports/location/:project_id/backers" => "reports#location_by_project", :as => :backers_location_report
  match "/reports/users_most_backed" => "reports#users_most_backed", :as => :most_backed_report
  match "/reports/all_confirmed_backers" => "reports#all_confirmed_backers", :as => :all_confirmed_backers_report
  match "/reports/all_projects_owners" => "reports#all_projects_owner", :as => :all_projects_owner_report
  match "/reports/all_emails" => "reports#all_emails_to_newsletter", :as => :all_emails_to_newsletter

  # Static Pages
  match '/sitemap' => "static#sitemap", :as => :sitemap
  match "/guidelines" => "static#guidelines", :as => :guidelines
  match "/faq" => "static#faq", :as => :faq
  match "/terms" => "static#terms", :as => :terms
  match "/privacy" => "static#privacy", :as => :privacy

  match "/thank_you" => "payment_stream#thank_you", :as => :thank_you
  match "/explore" => "explore#index", :as => :explore
  match "/explore#:quick" => "explore#index", :as => :explore_quick
  match "/credits" => "credits#index", :as => :credits

  post "/auth" => "sessions#auth", :as => :auth
  match "/auth/:provider/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"
  match "/logout" => "sessions#destroy", :as => :logout
  resources :posts, only: [:index, :create]
  resources :projects, only: [:index, :new, :create, :show] do
    resources :updates, :only => [:index, :create, :destroy]
    resources :rewards
    resources :backers, controller: 'projects/backers' do
      collection do
        post 'review'
      end
      member do
        put 'checkout'
        post 'update_info'
      end
    end
    collection do
      get 'start'
      post 'send_mail'
      get 'vimeo'
      get 'check_slug'
      get 'cep'
      get 'pending'
      get 'pending_backers'
      get 'thank_you'
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
    member do
      get 'projects'
      get 'credits'
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

  resources :curated_pages do
    collection do
      post 'update_attribute_on_the_spot'
    end
  end
  match "/pages/:permalink" => "curated_pages#show", as: :curated_page

  namespace :adm do
    resources :backers do
      collection do
        post 'update_attribute_on_the_spot'
      end
    end
    resources :users
  end

  resources :tests

  match "/:permalink" => "projects#show", as: :project_by_slug

end
