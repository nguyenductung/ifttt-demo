module SessionsHelper
  def sign_in user
    session[:user_id] = user.id
    self.current_user = user
  end

  def sign_out
    session.delete :user_id
    self.current_user = nil
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user= user
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def current_user? user
    user == current_user
  end

  def authenticate_user
    unless signed_in?
      redirect_to sign_in_path
    end
  end
end
