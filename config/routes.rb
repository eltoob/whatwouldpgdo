Rails.application.routes.draw do
  resources :conversations do
    post "create_message", on: :member
  end
  root "conversations#new"
end
