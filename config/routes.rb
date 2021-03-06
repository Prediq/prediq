Rails.application.routes.draw do
  root 'example_pages#welcome'
  
  devise_for :users

  get '/dashboard' => 'example_pages#dashboard'

  scope :path => :cms do

    get '/',  to: "dashboard#index", as: 'default_route'

    # devise_scope :admin do
    #   get "/admins/sign_up",  :to => "dashboard#index"
    # end

    # devise_for :admins

    devise_for :admins, :controllers => {
                          :registrations  => 'registrations'
                      }


    resources :admins, :only => [:index] #:controller => 'admins' # , :controller => 'admins' # for maintenance of the Admin Users => the prediq_api codebase uses a 'admins_controller'

    resources :user, :controller => 'user', only: [:index,:edit,:show,:update]   # for basic maintenance of the customer users

    # NOTE: deactivates the self-registration in the CMS while still enabling devise functionalities related to self registration
    # match '/admins/sign_up', :to => 'devise/sessions#new', :via => [:get]

    match 'users', :to => 'user#index', as: :users_path, :via => [:get]

    # match '/sign_in' => "devise/sessions#new", :as => :login, :via => [:post]

    # admin routes
    resources :dashboard, :except => [:edit,:show,:update,:destroy,:new] do #, :only => [ :index ] # Main screen
    end
    resources :admin #, :except => [:show] #  :only => [ :index, :show, :new, :edit, :create, :update, :destroy ]

  end  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
