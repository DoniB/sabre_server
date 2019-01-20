class CreateIngredientsRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :ingredients_recipes do |t|
      t.belongs_to :recipe
      t.belongs_to :ingredient
    end

    add_index :ingredients_recipes,
              [:recipe_id, :ingredient_id],
              unique: true
  end
end
