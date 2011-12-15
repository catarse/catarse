Catarse::Application.routes.draw do
  ActiveAdmin.routes(self)

  filter :locale

  root :to => "projects#index"
  match "/reports/financial/:project_id/backers" => "reports#financial_by_project", :as => :backers_financial_report

  match "/guidelines" => "projects#guidelines", :as => :guidelines
  match "/faq" => "projects#faq", :as => :faq
  match "/terms" => "projects#terms", :as => :terms
  match "/privacy" => "projects#privacy", :as => :privacy
  match "/thank_you" => "payment_stream#thank_you", :as => :thank_you
  match "/moip" => "payment_stream#moip", :as => :moip
  match "/explore" => "explore#index", :as => :explore
  match "/explore/:quick" => "explorer#index", :as => :explore_quick
  match "/credits" => "credits#index", :as => :credits

  post "/auth" => "sessions#auth", :as => :auth
  match "/auth/:provider/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"
  match "/logout" => "sessions#destroy", :as => :logout
  if Rails.env == "test"
    match "/fake_login" => "sessions#fake_create", :as => :fake_login
  end
  resources :projects, :only => [:index, :new, :create, :show] do
    resources :rewards
    collection do
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

  resources :paypal, :only => [] do
    member do
      get 'pay'
      get 'success'
      get 'cancel'
    end
  end

  resources :curated_pages do
    collection do
      post 'update_attribute_on_the_spot'
    end
  end
  match "/:permalink" => "curated_pages#show", :as => :curated_page
end
