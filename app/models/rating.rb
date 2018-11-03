class Rating < ApplicationRecord
  validates :stars, :user_id, :recipe_id, presence: true
  validates :stars, numericality: { only_integer:             true,
                                    greater_than_or_equal_to: 0,
                                    less_than_or_equal_to:    5}
  validates_uniqueness_of :id, scope: [:recipe_id, :user_id]

  belongs_to :user
  belongs_to :recipe

end
