# frozen_string_literal: true

class AddDeletedAtToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :deleted_at, :datetime, default: nil
    add_reference :comments, :deleted_by_user, references: :users
  end
end
