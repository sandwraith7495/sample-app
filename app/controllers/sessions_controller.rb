class SessionsController < ApplicationController
  def new; end

  def create
    session = params[:session]
    user = User.find_by email: session[:email].downcase

    if user && user.authenticate(session[:password])
      if user.activated?
        login_success user
      else
        messages
      end
    else
      login_fail
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def messages
    message = t "account_not_activated"
    flash[:warning] = message
    redirect_to root_url
  end

  def login_success user
    log_in user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
    redirect_back_or user
  end

  def login_fail
    flash.now[:danger] = t "invalid_email"
    render :new
  end
end
