class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.integer  :user_id
      t.integer  :m_recipe_id
      t.string   :object
      t.datetime :last_executed_at
      t.datetime :executes_at
      t.integer  :interval

      t.timestamps
    end
  end
end
