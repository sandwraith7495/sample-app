module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  def remember user
    user.remember
    cookies_permanent = cookies.permanent
    cookies_permanent.signed[:user_id] = user.id
    cookies_permanent[:remember_token] = user.remember_token
  end

  def current_user
    session_id = session[:user_id]
    cookies_id = cookies.signed[:user_id]

    if session_id
      @current_user ||= User.find_by id: session_id
    elsif cookies_id
      user = User.find_by id: cookies_id
      user_authenticate user if user && user.authenticated?
      cookies[:remember_token]
    end
  end

  def current_user? user
    user == current_user
  end

  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    forget current_user
    session.delete :user_id
    @current_user = nil
  end

  def redirect_back_or default
    redirect_to session[:forwarding_url] || default
    session.delete :forwarding_url
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  private

  def user_authenticate user
    log_in user
    @current_user = user
  end
end
