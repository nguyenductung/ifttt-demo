class UsersController < ApplicationController
  before_action :authenticate_user, :check_user, only: :show

  def show
  end

  private

  def check_user
    redirect_to user_path(current_user) if current_user && current_user.id != params[:id].to_i
  end
end