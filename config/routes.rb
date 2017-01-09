Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
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

  root 'people#index'

  get 'people/new' => "people#new"

  post 'people/create' => "people#create"

  get '/people/view' => "people#view"

  get '/people/view/:id' => "people#show"

  get '/people/edit/:id/:field' => "people#edit_field"

  post 'update_field' => "people#update_field"

  get '/people/all' => "people#all"

  get "/get_first_names" => "people#get_first_names"
  
  get "/get_last_names" => "people#get_last_names"

  get '/facilities' => "people#facilities"

  get '/nationalities' => "people#nationalities"

  get '/districts' => "people#districts"

  get "/tas" => "people#tas"

  get "/villages" => "people#villages"

  get "/logout" => "logins#logout"
  
  get "/change_password" => "users#change_password"

  get "/login" => "logins#login"

  get "/view_users" => "users#view"

  get "/edit_account" => "users#edit_account"

  get "/query_users" => "users#query"

  get "/search_user" => "users#search"

  resources :users

  resource :login do
    collection do
      get :logout
    end
  end
end
