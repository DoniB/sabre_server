# frozen_string_literal: true

class Comment < ApplicationRecord
  validates :text, :user_id, :recipe_id, presence: true
  validates :text, length: { minimum: 10 }

  belongs_to :user
  belongs_to :deleted_by_user, class_name: "User", optional: true
  belongs_to :recipe

  scope :active, -> { where(deleted_at: nil, deleted_by_user_id: nil) }

  def as_json(options = {})
    super(options).merge(
      username: user.username
    )
  end

  def deleted_by_user=(u)
    self.deleted_at = Time.now
    super(u)
  end

  def soft_delete(del_user)
    self.deleted_by_user = del_user
    save
  end
end
