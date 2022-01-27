Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, controllers: { sessions: "users/sessions" }

  devise_scope :user do  
    post '/users/sign_in' => 'devise/sessions#create'
    get '/users/sign_out' => 'devise/sessions#destroy'     
  end
 
  root 'home#index'
  
  get '/uploads/start(/:id)' => 'uploads#start', :as => 'start_upload'
  post '/uploads/start(/:id)' => 'uploads#create'
  resources :uploads
  
  post '/projects/new' => 'projects#create'
  get '/projects/update(/:id)' => 'projects#edit', :as => 'project_update'
  post '/projects/update' => 'projects#update'
  get '/projects/run(/:id)' => 'projects#run', :as => 'run_project'
  get '/projects/do_run(/:id)' => 'projects#do_run', :as => 'do_run_project'
  get '/projects/retrieve(/:access_key)' => 'projects#retrieve', :as => 'retrieve_project'
  get '/projects/retrieve_dl(/:access_key)' => 'projects#retrieve_dl', :as => 'retrieve_dl_project'
  resources :projects
  
end
