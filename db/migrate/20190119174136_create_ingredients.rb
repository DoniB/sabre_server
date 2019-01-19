class CreateIngredients < ActiveRecord::Migration[5.2]
  def change
    enable_extension "citext"
    create_table :ingredients do |t|
      t.citext :name, unique: true
      t.timestamps
    end
  end
end
