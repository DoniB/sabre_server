# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'factory_bot_rails'
require 'recipe_status'

if Recipe.count == 0
  40.times { FactoryBot::create :recipe, status: RecipeStatus::ACTIVE }
  30.times { FactoryBot::create :recipe, status: RecipeStatus::WAITING_ACTIVATION }
  20.times { FactoryBot::create :recipe, status: RecipeStatus::REJECTED }
  10.times { FactoryBot::create :recipe, status: RecipeStatus::PAUSED }
end

