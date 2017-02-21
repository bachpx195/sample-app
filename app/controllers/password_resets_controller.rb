class PasswordResetsController < ApplicationController
  before_action :find_user, :valid_user, :check_expiration,
    only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_path
    else
      flash.now[:danger] = "Email address not found"
      render :new
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, "can't be empty"
      render :edit
    elsif @user.update_attributes user_params
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def find_user
    @user = User.find_by email: params[:email]
    unless @user
      flash[:error] = "Email not found!"
      redirect_to root_path
    end
  end

  def valid_user
    unless @user && @user.activated? &&
      @user.authenticated?(:reset, params[:id])
      flash[:error] = "Valid user!"
      redirect_to root_path
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_path
    end
  end
end
