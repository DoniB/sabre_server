# frozen_string_literal: true

class Ingredient < ApplicationRecord
  include PgSearch

  has_and_belongs_to_many :recipes
  validates :name, uniqueness: true,
                   presence: true

  PAGE_LIMIT = 20

  default_scope -> { order(id: :desc) }
  scope :page, -> (pg = 0) { limit(PAGE_LIMIT).offset(pg.to_i * PAGE_LIMIT) }

  pg_search_scope(
    :search,
    against: :name,
    using: {
        tsearch: {
            dictionary: "portuguese",
            prefix: true
        },
        dmetaphone: {
            any_word: true
        },
        trigram: {
            threshold: 0.3
        }
    },
    ignoring: :accents
  )
end
