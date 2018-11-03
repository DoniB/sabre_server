class CreateRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :ratings do |t|
      t.integer :stars
      t.belongs_to :user
      t.belongs_to :recipe

      t.timestamps
    end
  end
end
