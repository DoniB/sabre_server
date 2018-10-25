class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.string :text
      t.belongs_to :user
      t.belongs_to :recipe

      t.timestamps
    end
  end
end
