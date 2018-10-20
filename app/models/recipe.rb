require 'recipe_status'

class Recipe < ApplicationRecord
  validates :ingredients, :name, :directions, presence: true
  PAGE_LIMIT = 20

  belongs_to :user

  default_scope -> { order(id: :asc) }

  scope :active, -> { where('status = ?', RecipeStatus::ACTIVE) }
  scope :waiting_activation, -> { where('status = ?', RecipeStatus::WAITING_ACTIVATION) }
  scope :page, -> (p = 0) { limit(PAGE_LIMIT).offset(p * PAGE_LIMIT) }

end
