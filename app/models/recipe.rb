require 'recipe_status'

class Recipe < ApplicationRecord
  validates :ingredients, :name, :directions, presence: true

  belongs_to :user

  scope :active, -> { where('is_admin = ?', true) }
  scope :waiting_activation, -> { where('status = ?', RecipeStatus::WAITING_ACTIVATION) }

end
