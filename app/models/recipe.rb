# frozen_string_literal: true

require "recipe_status"
require "set"

class Recipe < ApplicationRecord
  include PgSearch

  validates :ingredients, :name, :directions, presence: true
  validates :average_stars, numericality: { only_integer:             true,
                                            greater_than_or_equal_to: 0,
                                            less_than_or_equal_to:    5 }
  PAGE_LIMIT = 20

  belongs_to :user
  belongs_to :category
  belongs_to :cover, class_name: "Image", optional: true
  has_many :comments
  has_many :ratings
  has_and_belongs_to_many :ingredients_list, class_name: "Ingredient"

  default_scope -> { order(id: :desc) }

  scope :active, -> { where("status = ?", RecipeStatus::ACTIVE) }
  scope :waiting_activation, -> { where("status = ?", RecipeStatus::WAITING_ACTIVATION) }
  scope :page, -> (pg = 0) { limit(PAGE_LIMIT).offset(pg.to_i * PAGE_LIMIT) }
  scope :category, -> (cat) { where("category_id = ?", cat) }

  pg_search_scope(
    :search,
    against: %i(
      name
      ingredients
    ),
    using: {
        tsearch: {
            dictionary: "portuguese",
            prefix: true,
            tsvector_column: "tsv"
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

  def as_json(options = {})
    ret = super(options)
    ret[:owner] = user.username if self.user_id
    if self.cover&.file&.image?
      ret[:cover] = Rails.application.routes.url_helpers.rails_representation_url cover.file.variant(resize: "600x450")
    end
    ret
  end

  def self.by_ingredients_list(list)
    recipes = []
    ingredients = Ingredient.from_comma_list(list)
    ingredients.
        each { |ingredient|
          recipes = select_recipes_by_ingredients(ingredient, recipes, ingredients)
        }
    recipes
  end

  def self.select_recipes_by_ingredients(ingredient, recipes, ingredients)
    ingredient.recipes.each { |recipe|
      unless recipes.include? recipe
        recipes << recipe if recipe.can_be_done_with ingredients
      end
    }
    recipes
  end

  def update_average_stars
    self.average_stars = ratings.average(:stars).to_i
    save
  end

  def can_be_done_with(list)
    self.ingredients_list.each { |ingredient|
      return false unless list.include? ingredient
    }
    true
  end
end
