class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception

	before_filter :configure_permitted_parameters, if: :devise_controller?

  utf8_enforcer_workaround

	protected
	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :first_name, :last_name, :country) }
		devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :first_name, :last_name, :country) }
	end
end
