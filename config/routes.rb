Rails.application.routes.draw do
  get 'sessions/new'

  root 'static_pages#home'
  get 'signup' => 'users#new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  resources :users
  resources :posts , only: [:create , :destroy ,:show]
  resources :relationships , only: [:create , :destroy , :show]
  resources :prefs , only: [:create , :destroy , :show]




  post 'api/v1/login'             => 'api/users#login'
  post 'api/v1/register'          => 'api/users#register'
  post 'api/v1/set_home_location' => 'api/posts#set_home_locaiton'
  post 'api/v1/profile'           => 'api/users#edit_profile'
  get  'api/v1/profile'           => 'api/users#show_profile'
  get  'api/v1/prefs'             => 'api/users#get_prefs'
  post 'api/v1/prefs'             => 'api/users#edit_prefs'
  post 'api/v1/follow'            => 'api/users#follow'
  get  'api/v1/following'         => 'api/users#get_following'
  get  'api/v1/followers'         => 'api/users#get_followers'
  post 'api/v1/posts'             => 'api/posts#add_post'
  get 'api/v1/post'             => 'api/posts#find_post'
  get 'api/v1/remove_post'      => 'api/posts#remove_post'
  get  'api/v1/feed'              => 'api/posts#feed'
  get  'api/v1/show'              => 'relationships#show'


  resources :base


end
