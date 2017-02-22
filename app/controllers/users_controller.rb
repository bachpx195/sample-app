class UsersController < ApplicationController
  before_action :logged_in_user, :correct_user, except: [ :new, :create, :show]
  before_action :find_user, only: [:show, :destroy, :edit, :update]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @users = User.paginate page: params[:page]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @microposts = @user.microposts.paginate page: params[:page]
    @current_user_create_follower = current_user.active_relationships.build
    @current_user_destroy_follower = current_user.active_relationships.
      find_by followed_id: @user.id
  end

  def edit
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    flash[:success] = "User deleted"
    redirect_to users_path
  end

  private
  def find_user
    @user = User.find_by id: params[:id]
    unless @user
      flash[:error] = "User not found!"
      redirect_to root_path
    end
  end

  def user_params
    params.require(:user).permit :name, :email, :birthday,
      :password, :password_confirmation
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_path
    end
  end

  def correct_user
    redirect_to root_path unless @user.current_user? current_user
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
