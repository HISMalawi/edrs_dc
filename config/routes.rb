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

  root 'application#index'

  get '/people/' => "people#index"

  get '/dc/' => "dc#index"

  get 'people/new' => "people#new"

  get 'people/new_split' => "people#new_split"

  post 'people/create' => "people#create"

  post "/search_similar_record" => "people#search_similar_record"

  get "/search_similar_record" => "people#search_similar_record"

  get '/people/view' => "people#view"

  get '/people/view/:id' => "people#show"

  get '/people/edit/:id/:field' => "people#edit_field"

  get '/cause_of_death/:id' => "people#render_cause_of_death_page"

  get '/add_cause_of_death/:id' => "people#add_cause_of_death"

  post '/update_cause_of_death'  => "people#update_cause_of_death"

  get '/people/print_id_label' =>"people#print_id_label"

  get '/search_by_status' => "people#search_by_status"

  post 'update_field' => "people#update_field"

  get '/people/all' => "people#all"

  get '/people/finalize_create/:id' => "people#finalize_create"

  get "/get_first_names" => "people#get_first_names"
  
  get "/get_last_names" => "people#get_last_names"

  get '/facilities' => "people#facilities"

  get '/nationalities' => "people#nationalities"

  get '/districts' => "people#districts"

  get "/tas" => "people#tas"

  get "/villages" => "people#villages"



  get "/check_completeness/:id" =>"dc#check_completeness"

  get "/dc/manage_cases" =>"dc#manage_cases"

  get "/dc/approve_cases" => "dc#approve_cases"

  get "/dc/approve_record/:id" => "dc#approve_record"

  get "/dc/add_rejection_comment/:id" => "dc#add_rejection_comment"

  get "/dc/counts_by_status" => "dc#counts_by_status"

  post "/reject_record" => "dc#reject_record"

  get "/dc/approved_cases" => "dc#approved_cases"

  get "/dc/rejected_cases" =>"dc#rejected_cases"

  get "dc/closed" => "dc#closed"

  get "dc/dispatched" => "dc#dispatched"

  get "/dc/voided" => "dc#voided"

  get "/dc/pending_cases" => "dc#pending_cases"

  get "/dc/manage_duplicates" => "dc#manage_duplicates"

  get "/dc/manage_requests" => "dc#manage_requests"

  get "/dc/potential_duplicates" => "dc#potential_duplicates"

  get "/dc/show_duplicate/:id" =>"dc#show_duplicate"

  get "/confirm_record_not_duplicate_comment/:id/:audit_id" => "dc#confirm_record_not_duplicate_comment"

  get "/confirm_duplicate_comment/:id/:audit_id" => "dc#confirm_duplicate_comment"

  post "/confirm_duplicate" => "dc#confirm_duplicate"

  post "/confirm_not_duplicate" => "dc#confirm_not_duplicate"

  get "/dc/new_burial_report/:id" => "dc#new_burial_report"

  post "/create_burial_report" => "dc#create_burial_report"

  get "/dc/add_pending_comment/:id" => "dc#add_pending_comment"

  post "/mark_as_pending" => "dc#mark_as_pending"




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
