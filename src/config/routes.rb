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
  get '/projects/run(/:id)' => 'projects#run', :as => 'run_project'
  get '/projects/retrieve(/:access_key)' => 'projects#retrieve', :as => 'retrieve_project'
  resources :projects
  
end
