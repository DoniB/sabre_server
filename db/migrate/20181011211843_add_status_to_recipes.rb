require 'recipe_status'
class AddStatusToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :status, :integer, limit: 1, default: RecipeStatus::WAITING_ACTIVATION
  end
end
