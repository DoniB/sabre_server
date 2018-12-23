class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.belongs_to :user
      t.belongs_to :recipe

      t.timestamps
    end
  end
end
