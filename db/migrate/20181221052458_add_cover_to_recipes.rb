class AddCoverToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_reference :recipes, :cover, references: :images
  end
end
