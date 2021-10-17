class UserMailer < ApplicationMailer

  default from: Rails.application.secrets.default_from

    def test_welcome_email(user_email)
      # @user = User.first#params[:user]
      # @url  = 'http://example.com/login'
      @user_email = user_email
      # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
      mail(to: Rails.application.secrets.default_to,
          reply_to: @user_email ,
          subject: 'Новая регистрация в нашем приложении')
    end

end
