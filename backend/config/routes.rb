Geocms::Core::Engine.add_routes do

  resources :users, :only => [:new, :create]

  namespace :backend do
    root :to => "categories#index"

    get "search", :to => "search#search", as: :search

    resources :categories do
      member do
        get "move", :to => "categories#move"
      end
      resources :layers
    end

    resources :layers, :only => [:index, :create, :edit, :update, :new, :destroy] do
      member do
        get "getfeatures", :to => "layers#getfeatures"
      end
    end

    resources :data_sources do
      member do
        get "import"
      end
    end

    resources :preferences, :only => [] do
      collection do
        get "edit"
        put "update"
      end
    end

    resources :users, :only => [:index, :new, :create, :edit, :update, :destroy] do
      collection do
        get "network"
        post "add"
      end
      resources :roles
    end

    resources :memberships

    resources :accounts

    resources :folders do
      resources :contexts
    end

  end
end
