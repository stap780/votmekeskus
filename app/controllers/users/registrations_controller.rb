class Users::RegistrationsController < Devise::RegistrationsController
  after_action :send_admin_email, only: [:create]


  # # # GET /resource/sign_up
  # def new
  #   super
  # end

  # # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  def send_admin_email
    if current_user.present?
      UserMailer.test_welcome_email(current_user.email).deliver_now
    end
  end
end
