class CreateSecureTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :secure_tokens do |t|
      t.string :token, unique: true
      t.datetime :expires
      t.belongs_to :user
      t.datetime :created_at
    end
  end
end
