require 'recipe_status'

class Recipe < ApplicationRecord
  include PgSearch

  validates :ingredients, :name, :directions, presence: true
  validates :average_stars, numericality: { only_integer:             true,
                                            greater_than_or_equal_to: 0,
                                            less_than_or_equal_to:    5 }
  PAGE_LIMIT = 20

  belongs_to :user
  belongs_to :category
  has_many :comments
  has_many :ratings

  default_scope -> { order(id: :desc) }

  scope :active, -> { where('status = ?', RecipeStatus::ACTIVE) }
  scope :waiting_activation, -> { where('status = ?', RecipeStatus::WAITING_ACTIVATION) }
  scope :page, -> (p = 0) { limit(PAGE_LIMIT).offset(p * PAGE_LIMIT) }
  scope :category, -> (c) { where('category_id = ?', c) }

  pg_search_scope(
    :search,
    against: %i(
      name
      ingredients
    ),
    using: {
        tsearch: {
            dictionary: 'portuguese'
        }
    }
  )

  def as_json(options = {})
    super(options).merge({
      owner: user.username
    })
  end

  def update_average_stars
    self.average_stars =  ratings.average(:stars).to_i
    save
  end

end
