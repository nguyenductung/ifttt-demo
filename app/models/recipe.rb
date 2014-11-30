class Recipe < ActiveRecord::Base
  belongs_to :m_recipe, class_name: M::Recipe.name
  belongs_to :user

  after_commit :execute_recipe, on: :create
  after_create -> { self.last_executed_at = Time.current }

  validates_presence_of :user_id, :m_recipe_id
  validate :check_provider

  UPDATEABLE_COLUMNS = [:user_id, :m_recipe_id, :object, :executes_at, :last_executed_at, :interval]

  private

  def execute_recipe
    if m_recipe.m_id == 1
      m_recipe.name.camelize.constantize.perform_at executes_at, id
    end
  end

  def check_provider
    unless user.connected? m_recipe.required_providers
      errors.add :base, "Connections required."
    end
  end
end