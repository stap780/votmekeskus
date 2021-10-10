class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @search = User.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @users = @search.result.paginate(page: params[:page], per_page: 30)
  end

  def show
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to root_path, :alert => "Access denied."
    end
  end

end
