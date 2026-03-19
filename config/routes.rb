Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "auth/signup", to: "authentication#signup"
  post "auth/login", to: "authentication#login"

  namespace :api do
    namespace :v1 do
      resources :employees do
        resource :salary, only: [:show], controller: "salary_calculations"
      end

      get "salary_metrics/by_country", to: "salary_metrics#by_country"
      get "salary_metrics/by_job_title", to: "salary_metrics#by_job_title"
    end
  end
end
