class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :allow_cross_domain_ajax
  helper_method :current_admin
  helper_method :authenticate_admin!
  helper_method :authenticate_user_role!


  def allow_cross_domain_ajax
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Request-Method'] = 'GET, POST, OPTIONS'
  end

  private

  def current_admin
      current_user.role.name == 'admin' ? true : false
  end

  def authenticate_admin!
    unless current_admin
      redirect_to root_path, alert: "У вас нет прав админа"
    end
  end

  def authenticate_user_role!
    if current_user.role.name == 'registered'
      redirect_to root_path, alert: "Дождитесь проверки от админа. Мы отправили ему письмо про вашу регистрацию"
    end
  end

protected

# If you have extra params to permit, append them to the sanitizer.
def configure_permitted_parameters
  attributes = [:name, :email, :role_id, :encrypted_password, :password_confirmation, :remember_me]
  devise_parameter_sanitizer.permit(:sign_in, keys: attributes)
  devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
  devise_parameter_sanitizer.permit(:account_update, keys: attributes)
end


end
