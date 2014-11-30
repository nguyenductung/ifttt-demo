class CreateMRecipes < ActiveRecord::Migration
  def change
    create_table :m_recipes do |t|
      t.integer :m_id
      t.string  :name
      t.string  :description
      t.string  :image
      t.string  :source
      t.string  :target
      t.string  :trigger
      t.string  :action
      t.string  :object_type
      t.boolean :multiple

      t.timestamps
    end
  end
end
