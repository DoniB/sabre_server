class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :username, required: true
      t.string :email, unique: true, required: true
      t.string :password
      t.string :password_digest

      t.timestamps
    end
  end
end
