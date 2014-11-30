namespace :db do
  task import_recipes: :environment do
    CSV.foreach('db/recipes.csv', headers: true) do |row|
      M::Recipe.find_or_create_by row.to_hash
    end
  end
end