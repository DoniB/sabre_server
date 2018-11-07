class AddCategoryToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_reference :recipes, :category, foreign_key: true

    if Category.count > 0 && Recipe.count > 0
      Recipe.all.each do |r|
        r.update category: Category.all.sample
      end
    end
  end
end
