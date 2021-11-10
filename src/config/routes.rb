Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, controllers: { sessions: "users/sessions" }

  devise_scope :user do  
    post '/users/sign_in' => 'devise/sessions#create'
    get '/users/sign_out' => 'devise/sessions#destroy'     
  end
 
  root 'home#index'
  
  post '/projects/new' => 'projects#create'
  get '/projects/run' => 'projects#run', :as => 'run_project'
  get '/projects/upload(/:id)' => 'projects#upload', :as => 'project_upload'
  resources :projects
  
end
