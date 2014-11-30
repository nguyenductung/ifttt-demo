class PostMessageToTwitterAtSpecificTime
  include Sidekiq::Worker

  def perform recipe_id
    recipe = Recipe.find_by id: recipe_id
    return unless recipe
    recipe.user.twitter_client.update recipe.object
  end
end
