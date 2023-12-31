Rails.application.routes.draw do
  resources :dispensers, only: %i[index show create] do
    member do
      post :open
      post :close
      get :calculate_spend
    end
  end
end
