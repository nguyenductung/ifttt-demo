class RecipesController < ApplicationController
  before_action :authenticate_user
  before_action :load_object, only: :destroy

  def create
    recipe = current_user.recipes.build recipe_params
    if recipe.save
      redirect_to user_path(current_user), notice: "Recipe enabled successfully."
    else
      redirect_to user_path(current_user), flash: { error: "Could not enable recipe. Please try again." }
    end
  end

  def destroy
    @recipe.destroy
    redirect_to user_path(current_user)
  end

  private

  def load_object
    @recipe = current_user.recipes.find_by id: params[:id]
    redirect_to user_path(current_user) unless @recipe
  end

  def recipe_params
    params[:recipe] ||= {}
    params[:recipe][:last_executed_at] = Time.current
    params.require(:recipe).permit(Recipe::UPDATEABLE_COLUMNS)
  end
end