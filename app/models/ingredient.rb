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

  pg_search_scope(
    :fuzzy_search,
    against: :name,
    using: {
        tsearch: {
            dictionary: "portuguese",
            prefix: true
        },
        dmetaphone: {
            any_word: true
        }
    },
    ignoring: :accents
  )

  pg_search_scope(
    :trigram_search,
      against: :name,
      using: {
          tsearch: {
              dictionary: "portuguese",
              prefix: true
          },
          trigram: {
              threshold: 0.4
          }
      },
      ignoring: :accents
  )

  def self.from_comma_list(list)
    list.
        split(",").
        map(&:strip).
        reject(&:empty?).map { |ingredient|
          Ingredient.where(name: ingredient).first ||
          Ingredient.fuzzy_search(ingredient).first ||
          Ingredient.trigram_search(ingredient).first
        }
  end
end
