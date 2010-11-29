Catarse::Application.routes.draw do

  root :to => "projects#index"

  match "/auth/:provider/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"
  match "/logout" => "sessions#destroy", :as => :logout
  
  resources :projects

end

