class Recipe < ApplicationRecord
  validates :ingredients, :name, :directions, presence: true

  belongs_to :user

end
