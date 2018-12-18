# frozen_string_literal: true

class Favorite < ApplicationRecord
  validates :recipe_id, uniqueness: { scope: [:user_id, :recipe_id] }

  belongs_to :user
  belongs_to :recipe
end
