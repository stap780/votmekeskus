class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_user_role!

  def index
    @search = User.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @users = @search.result.paginate(page: params[:page], per_page: 30)
  end

  def edit
    @user = User.find(params[:id])
  end

  def show
    @user = User.find(params[:id])
    # redirect_to root_path, alert: 'Access denied.' unless @user == current_user
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update(name: params[:user][:name], email: params[:user][:email], role_id: params[:user][:role_id])
        format.html { redirect_to @user, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @user = User.find(params[:id])
    if (User.count > 1) && !@user.admin?
      @user.destroy!

      respond_to do |format|
        format.html { redirect_to users_url, notice: 'Пользователь удалён' }
        format.json { head :no_content }
      end
    else
      redirect_to users_url, notice: 'Нельзя удалить последнего пользователя или админа'
    end
  end
end
