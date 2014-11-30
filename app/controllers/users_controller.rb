class UsersController < ApplicationController
  before_action :authenticate_user, :check_user, only: :show

  def show
    @m_recipes = M::Recipe.where(multiple: true).to_a +
      (M::Recipe.where(multiple: false).to_a - current_user.m_recipes)
    @recipes = current_user.recipes
  end

  private

  def check_user
    redirect_to user_path(current_user) if current_user.id != params[:id].to_i
  end
end