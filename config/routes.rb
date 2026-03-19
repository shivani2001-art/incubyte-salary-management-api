Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "auth/login", to: "authentication#login"

  namespace :api do
    namespace :v1 do
      resources :employees
    end
  end
end
