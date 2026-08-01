Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
  get "about", to: "pages#about", as: :about
  get "our-work", to: "pages#our_work", as: :our_work
  get "counseling", to: "pages#counseling", as: :counseling
  get "educational-support", to: "pages#educational_support", as: :educational_support
  get "get-involved", to: "pages#get_involved", as: :get_involved
  get "contact", to: "pages#contact", as: :contact
  post "contact", to: "contact_inquiries#create", as: :contact_inquiries
  get "privacy", to: "pages#privacy", as: :privacy
  get "terms", to: "pages#terms", as: :terms

  # Conference / Experience Archive
  resources :experiences, only: [:index, :show] do
    post "create_testimonial", on: :collection
  end

  # Interactive Form Flows
  resources :support_requests, path: "request-support", only: [:new, :create] do
    get "confirmation", on: :collection
  end

  resources :volunteer_applications, path: "volunteer", only: [:new, :create] do
    get "confirmation", on: :collection
  end

  resources :partnership_inquiries, path: "partner-with-us", only: [:new, :create] do
    get "confirmation", on: :collection
  end

  resources :donations, path: "donate", only: [:new, :create] do
    get "callback", on: :collection
    get "confirmation", on: :collection
    post "upload_receipt", on: :collection
  end

  resources :event_registrations, only: [:create]

  # Content Hub
  resources :stories, only: [:index, :show]
  resources :resources, only: [:index, :show]

  # Admin Authentication & Platform
  namespace :admin do
    get "login", to: "sessions#new", as: :login
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy", as: :logout

    get "/", to: "dashboard#index", as: :dashboard

    resources :contact_inquiries, only: [:index, :show, :update]
    resources :support_requests, only: [:index, :show, :update]
    resources :volunteer_applications, only: [:index, :show, :update]
    resources :partnership_inquiries, only: [:index, :show, :update]
    resources :events
    resources :stories
    resources :resources
    resources :testimonials
    resources :donations, only: [:index, :show, :update]
    resources :users

    post "uploads", to: "uploads#create"
    get "profile", to: "users#profile", as: :profile
    patch "profile", to: "users#update_profile"
    get "settings", to: "users#settings", as: :settings
  end

  # Custom Error Pages
  match "/404", to: "errors#not_found", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
end
