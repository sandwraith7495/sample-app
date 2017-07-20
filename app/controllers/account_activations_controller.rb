class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]

    if user && !user.activated? && user.authenticated?(:activation,
      params[:id])
      user.activate
      log_in user
      success user
    else
      danger
    end
  end

  private

  def danger
    flash[:danger] = t "invalid_link"
    redirect_to root_url
  end

  def success user
    flash[:success] = t "account_activated"
    redirect_to user
  end
end
