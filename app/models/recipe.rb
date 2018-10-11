class Recipe < ApplicationRecord
  validates :ingredients, :name, :directions, presence: true

  belongs_to :user

  scope :active, -> { where('is_admin = ?', true) }

end
