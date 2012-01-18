Catarse::Application.routes.draw do

  ActiveAdmin.routes(self)

  filter :locale

  root to: 'projects#index'

  # New design routes
  match '/new_blog' => 'static#new_blog'
  match '/new_profile' => 'static#new_profile'
  match '/new_project_profile' => 'static#new_project_profile'
  match '/new_discover' => 'static#new_discover'
  match '/new_payment' => 'static#new_payment'
  match '/new_opendata' => 'static#new_opendata'
  match '/new_curated_page' => 'static#new_curated_page'

  match "/reports/financial/:project_id/backers" => "reports#financial_by_project", :as => :backers_financial_report
  match "/reports/location/:project_id/backers" => "reports#location_by_project", :as => :backers_location_report

  # Static Pages
  match '/sitemap' => "static#sitemap", :as => :sitemap
  match "/guidelines" => "static#guidelines", :as => :guidelines
  match "/faq" => "static#faq", :as => :faq
  match "/terms" => "static#terms", :as => :terms
  match "/privacy" => "static#privacy", :as => :privacy

  match "/thank_you" => "payment_stream#thank_you", :as => :thank_you
  match "/moip" => "payment_stream#moip", :as => :moip
  match "/explore" => "explore#index", :as => :explore
  match "/explore#:quick" => "explore#index", :as => :explore_quick
  match "/credits" => "credits#index", :as => :credits

  post "/auth" => "sessions#auth", :as => :auth
  match "/auth/:provider/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"
  match "/logout" => "sessions#destroy", :as => :logout
  if Rails.env == "test"
    match "/fake_login" => "sessions#fake_create", :as => :fake_login
  end
  resources :posts, only: [:index, :create]
  resources :projects, only: [:index, :new, :create, :show] do
    resources :rewards
    resources :backers, controller: 'projects/backers' do
      collection do
        post 'review'
      end
      member do
        put 'checkout'
      end
    end
    collection do
      get 'start'
      post 'send_mail'
      get 'vimeo'
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
    member do
      get 'backs'
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

  resources :paypal, only: [] do
    member do
      get 'pay'
      get 'success'
      get 'cancel'
    end
  end

  resources :blog, only: :index do
  end
  
  resources :curated_pages do
    collection do
      post 'update_attribute_on_the_spot'
    end
  end
  match "/:permalink" => "curated_pages#show", as: :curated_page
end
