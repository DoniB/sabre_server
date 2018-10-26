require 'recipe_status'

class Recipe < ApplicationRecord
  include PgSearch

  validates :ingredients, :name, :directions, presence: true
  PAGE_LIMIT = 20

  belongs_to :user
  has_many :comments

  default_scope -> { order(id: :asc) }

  scope :active, -> { where('status = ?', RecipeStatus::ACTIVE) }
  scope :waiting_activation, -> { where('status = ?', RecipeStatus::WAITING_ACTIVATION) }
  scope :page, -> (p = 0) { limit(PAGE_LIMIT).offset(p * PAGE_LIMIT) }

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

end
