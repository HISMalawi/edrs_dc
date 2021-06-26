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

  ########################################## Routes for people controller####################################################

  get '/people/' => "people#index"

  get '/dc/' => "dc#index"

  get 'people/new' => "people#new"

  get "/remote_logout" =>"people#portal_logout"
  
  get 'people/new_split' => "people#new_split"

  get '/people/form_type'

  post 'people/create' => "people#create"

  post "/search_similar_record" => "people#search_similar_record"

  get "/search_similar_record" => "people#search_similar_record"

  get '/people/view' => "people#view"

  get '/people/view/:id' => "people#show"

  get "/people/unlock_record"

  get "/people/clear_all_locks"

  get '/people/edit/:id/:field' => "people#edit_field"

  get '/cause_of_death/:id' => "people#render_cause_of_death_page"

  get '/add_cause_of_death/:id' => "people#add_cause_of_death"

  post '/update_cause_of_death'  => "people#update_cause_of_death"

  get '/people/print_id_label' =>"people#print_id_label"

  get '/search_by_status' => "people#search_by_status"

  get "/search_by_status_with_prev_status" =>"people#search_by_status_with_prev_status"

  post 'update_field' => "people#update_field"

  get '/people/all' => "people#all"

  get "/people/search" => "people#search"

  get "/search_by_fields" => "people#search_by_fields"

  get "/general_search" => "people#general_search"

  get '/people/finalize_create/:id' => "people#finalize_create"

  get "/get_first_names" => "people#get_first_names"
  
  get "/get_last_names" => "people#get_last_names"

  get "/get_names" => "people#get_names"

  get '/facilities' => "people#facilities"

  get '/nationalities' => "people#nationalities"

  get '/countries' => "people#countries"

  get '/districts' => "people#districts"

  get "/tas" => "people#tas"

  get "/villages" => "people#villages"

  get "/other_countries" => "people#other_countries"

  get "/people/find/:id" =>"people#find"

  get "/find_by_barcode/:barcode" => "people#find_by_barcode"

  get "/people/new_person_type" => "people#new_person_type"

  get "/people/register_special_cases" =>"people#register_special_cases"

  post "/search_barcode" => "people#search_barcode"

  get "/search_barcode" => "people#search_barcode"

  post "/dispatch_barcodes" =>"dc#dispatch_barcodes"

  get "/dispatch_barcodes" =>"dc#dispatch_barcodes"

  get "/dc/manage_ccu_dispatch"

  get "/dc/view_ccu_dispatch"

  get "/dc/ccu_dispatches"

  get "/cause_dispatch/:id" => "dc#cause_dispatch"

  post "/find_identifier" =>"people#find_identifier"

  get "/find_identifier" =>"people#find_identifier"

  get "/global_phone_validation" => "people#global_phone_validation"

  get "/people/sync" => "people#view_sync"

  get "/people/query_dc_sync" =>"people#query_dc_sync"

  get "/view_special/:registration_type" =>"people#view_special"

  get "/query_registration_type/:registration_type" => "people#query_registration_type"

  get "/view_special_case_and_printed" => "people#view_special_case_and_printed"

  get "/query_registration_type_and_printed" => "people#query_registration_type_and_printed"

  get "/people/sync_data" => "people#sync_data"

  get "/people/form_container"

 

##############################################################################################################################################

################################ Routes for DC controller ####################################################################################

  get "/check_completeness/:id" =>"dc#check_completeness"

  get "/dc/manage_cases" =>"dc#manage_cases"

  get "/dc/special_cases" => "dc#special_cases"

  get "/dc/approve_cases" => "dc#approve_cases"

  get "/dc/approve_record/:id" => "dc#approve_record"

  get "/dc/add_reaprove_comment/:id" => "dc#add_reaprove_comment"

  post "/reaprove_record" =>"dc#reaprove_record"

  get "/reaprove_record" =>"dc#reaprove_record"

  get "/dc/check_approval_status/:id"=> "dc#check_approval_status"

  get "/dc/add_rejection_comment/:id" => "dc#add_rejection_comment"

  get "/dc/counts_by_status" => "dc#counts_by_status"

  post "/reject_record" => "dc#reject_record"

  get "/dc/approved_cases" => "dc#approved_cases"

  get "/dc/rejected_cases" =>"dc#rejected_cases"

  get "dc/closed" => "dc#closed"

  get "dc/dispatched" => "dc#dispatched"

  get "/dc/voided" => "dc#voided"

  get "/dc/manage_duplicates" => "dc#manage_duplicates"

  get "/dc/potential_duplicates" => "dc#potential_duplicates"

  get "/dc/exact_duplicates" => "dc#exact_duplicates"

  get "/dc/show_duplicate/:id" =>"dc#show_duplicate"

  get "/confirm_record_not_duplicate_comment/:id/:audit_id" => "dc#confirm_record_not_duplicate_comment"

  get "/confirm_duplicate_comment/:id/:audit_id" => "dc#confirm_duplicate_comment"

  post "/confirm_duplicate" => "dc#confirm_duplicate"

  post "/confirm_not_duplicate" => "dc#confirm_not_duplicate"

  get  "/dc/confirmed_duplicated" => "dc#confirmed_duplicated"

  get "/dc/new_burial_report/:id" => "dc#new_burial_report"

  post "/create_burial_report" => "dc#create_burial_report"

  get "/dc/pending_cases" => "dc#pending_cases"

  get "/dc/add_pending_comment/:id" => "dc#add_pending_comment"

  post "/mark_as_pending" => "dc#mark_as_pending"

  get "/dc/add_reprint_comment/:id" => "dc#add_reprint_comment"

  post "/mark_for_reprint" => "dc#mark_for_reprint"

  get "/dc/reprint_requests" => "dc#reprint_requests"

  get "/dc/approve_reprint/:id" => "dc#approve_reprint"

  get "/dc/manage_requests" => "dc#manage_requests"

  get "/dc/amendment_requests" => "dc#amendment_requests"

  get "/dc/do_amend/:id" =>"dc#do_amend"

  get "/dc/ammendment/:id" => "dc#amendment"

  get "/dc/amendment_edit_field/:id/:field" => "dc#amendment_edit_field"

  post "/amend_field" => "dc#amend_field"

  get "/dc/add_amendment_comment/:id" => "dc#add_amendment_comment"

  get "/dc/sent_to_hq_for_reprint/:id" =>"dc#sent_to_hq_for_reprint"

  post "/proceed_amend" => "dc#proceed_amend"

  get "/printed_amendmets" => "dc#printed_amendmets"

  get "/dc/sync" => "dc#sync"

  get "/dc/query_hq_sync" =>"dc#query_hq_sync"

####################################################################################################################################################################################

############################# Routes Users and Logins ####################################################################################
  get "/logout" => "logins#logout"

  get "/change_password" => "users#change_password"

  get "/login" => "logins#login"



  get "/login_wrapper" => "logins#login_wrapper"

  get "/view_users" => "users#view"

  get "/users/new"

  get "/edit_account" => "users#edit_account"

  get "/query_users" => "users#query"

  get "/search_user" => "users#search"

  get "/view_active" => "users#view_active"

  get "/view_blocked" => "users#view_blocked"

  get "/add_user_comment/:id" => "users#add_comment"

  post "/block_user" =>"users#block_user"

  post "/unblock_user" =>"users#unblock_user"

  get "/my_account" => "users#my_account"

  get "/users/show"

  get "/build_mysql" => "users#build_mysql"

  get '/build_mysql_database' => 'users#build_mysql_database'

  get 'create_mysql_database/:page_number/:records_per_page/:model_name/:table_name/:table_primary_key' => 'users#create_mysql_database'
  
  post '/database_load' => 'users#database_load'

  get "/confirm_username" => "users#confirm_username"
  post "/confirm_username" => "users#confirm_username"

  post "/confirm_password" =>"users#confirm_password"

  get "/confirm_password" =>"users#confirm_password"

  post "/update_password" => "users#update_password"

  get "/update_password" => "users#update_password"

  get "/users/change_user_password"

  get "/users/update_user_password"
  
  get 'database_load_progress/:table_name' => 'users#database_load_progress'

  get '/load_dumps' =>"users#load_dumps"

  get "keyboard_preference" => "users#keyboard_preference"

  get "/users/districts"

#################################Routes for duplicates#########################################################################
  get "/duplicate" =>"duplicate#index"
###############################################################################################################################
###############################################################################################################################
################################ Routes for Reports ###########################################################################
  get "/reports" => "reports#index"

  get "/death_reports" => "reports#death_reports"

  get "/report_data/:status" => "reports#report_data"

  get "/pick_dates" => "reports#pick_dates"

  get "/amendment_reports" => "reports#amendment_reports"

  get "/lost_damaged_reports" =>"reports#lost_damaged_reports"

  get "/voided_reports" => "reports#voided_reports"

  get "/voided_report_data" => "reports#voided_report_data"

  get "/lost_damaged_report_data" => "reports#lost_damaged_report_data"

  get "/amendment_report_data" => "reports#amendment_report_data"

  get "/reports/registration_type_and_gender"

  get "/reports/place_of_death_and_gender"

  get "/reports/by_date_of_death"

  get "/reports/by_date_of_death_and_gender"

  get "/reports/by_registartion_type"

  get "/reports/by_place_of_death"

  get "/people/view_datatable"

  get "/dc/cause_of_death_dispatch"

  get "/reports/user_audits"

  get "/reports/get_audits"

##############################################################################################################################

###################################################Decentralized printing###########################################################################
##############################################################################################################################
  get "/dc/print_certificates"
  get "dc/search_records_to_print"
  get "/dc/do_print_these"
  get "/death_certificate/:id" => "dc#death_certificate"
  get "/dc/printed"
  get "/dc/dc_printed"
  get "/dc/hq_printed"
  get "/application/hq_is_online"
  get "/dc/print_preview"


  get "/configs" => "users#configs"
  post "/save_configs" =>"users#save_configs"

  ############################Ajax Data Table ###########################################################################
  get 'add_more_open_cases/:page_number' => 'people#more_open_cases'

  resources :users

  resource :login do
    collection do
      get :logout
    end
  end
end
