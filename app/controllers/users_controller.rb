class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @search = User.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @users = @search.result.paginate(page: params[:page], per_page: 30)
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_path, alert: 'Access denied.' unless @user == current_user
  end

  def destroy
    @user = User.find(params[:id])
    if (User.count > 1) && !current_admin
      @user.destroy!

      respond_to do |format|
        format.html { redirect_to users_url, notice: 'user was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      redirect_to users_url, notice: 'Нельзя удалить последнего пользователя'
    end
  end
end
