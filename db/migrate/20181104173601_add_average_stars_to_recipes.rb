class AddAverageStarsToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :average_stars, :integer, default: 0
  end
end
