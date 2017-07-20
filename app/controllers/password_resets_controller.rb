class PasswordResetsController < ApplicationController
  before_action :getting_user, only: %i(edit update)
  before_action :valid_user, only: %i(edit update)
  before_action :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if user
      user.create_reset_digest
      user.send_password_reset_email
      flash[:info] = t "email_sent"
      redirect_to root_url
    else
      flash.now[:danger] = t "email_not_found"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      user.errors.add :password, t("can't_be_empty")
      render_edit
    elsif user.update_attributes user_params
      log_in user
      user.update_attributes reset_digest: nil
      success user
    else
      render_edit
    end
  end

  private

  attr_reader :user

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def getting_user
    @user = User.find_by email: params[:email]
  end

  def valid_user
    return if user && user.activated? && user.authenticated?(:reset,
      params[:id])
    redirect_to root_url
  end

  def render_edit
    render :edit
  end

  def check_expiration
    return unless user.password_reset_expired?
    flash[:danger] = t "password_expired"
    redirect_to new_password_reset_url
  end

  def success user
    flash[:success] = t "password_reseted"
    redirect_to user
  end
end
