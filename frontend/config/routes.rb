Geocms::Core::Engine.add_routes do

  root to: "pages#index"
  get "logout" => "sessions#destroy", as: "logout"
  get "login" => "sessions#new", as: "login"
  post "oauth/callback" => "oauths#callback"
  get "oauth/callback" => "oauths#callback" # for use with Github, Facebook
  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider
  resources :sessions, only: [:create]

  # serve compiled templates
  get 'templates/(*template_name)', :to => 'static#template'
  # routes accessible and defined in angular app
  get '/maps(*foo)', to: "pages#index"
  get '/projects(*foo)', to: "pages#index"
end
