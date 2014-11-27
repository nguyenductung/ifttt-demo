class SessionsController < ApplicationController
  def new
    redirect_to user_path(current_user) if current_user
  end

  def create
    if user = User.find_or_create_with_omniauth(request.env['omniauth.auth'], current_user)
      notice = current_user ? "Connected successfully." : "Signed in successfully."
      sign_in user unless current_user
      redirect_to user_path(current_user), notice: notice
    else
      error = current_user ? "Could not sign in. Please try again." : "Could not connect. Please try again."
      redirect_to root_path, flash: { error: error }
    end
  end

  def destroy
    if current_user
      sign_out
      redirect_to root_path, notice: "You have been signed out."
    else
      redirect_to user_path(current_user)
    end
  end
end
