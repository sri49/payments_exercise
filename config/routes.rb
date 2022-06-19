Rails.application.routes.draw do
	resources :loans, defaults: {format: :json} do
		member do
			get :show_payment
			get :show_payments
			post :add_payment
		end
	end
end
