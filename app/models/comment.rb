class Comment < ApplicationRecord
  validates :text, :user_id, :recipe_id, presence: true
  validates :text, length: { minimum: 10 }

  belongs_to :user
  belongs_to :recipe

  def as_json(options = {})
    super(options).merge({
        username: user.username
    })
  end

end
