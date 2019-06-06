# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'factory_bot_rails'
require 'recipe_status'

if Recipe.count == 0 && Rails.env.development?
  40.times { FactoryBot.create :recipe, status: RecipeStatus::ACTIVE }
  30.times { FactoryBot.create :recipe, status: RecipeStatus::WAITING_ACTIVATION }
  20.times { FactoryBot.create :recipe, status: RecipeStatus::REJECTED }
  10.times { FactoryBot.create :recipe, status: RecipeStatus::PAUSED }
end

if Category.count == 0
  [
    'Bolos e Tortas', 'Carnes', 'Aves', 'Peixes e Frutos do Mar', 'Saladas e Molhos',
    'Sopas', 'Massas', 'Bebidas', 'Doces e Sobremesas', 'Lanches', 'Alimentação Saudável'
  ].each do |c|
    Category.create name: c
  end
end

if ENV['JMETER'] == '1'
  puts 'SEED: JMETER'
  puts "SABRE_DATABASE: #{ENV['SABRE_DATABASE']}"
  ingredients_plain = File.read(Rails.root.join('jmeter', 'ingredients.cvs')).split("\n")
  ingredients = ingredients_plain.map { |i| Ingredient.create name: i }
  category = Category.first
  user = FactoryBot.create :user

  (1..(ingredients.size)).each do |i|
    ingredients.combination(i).each do |c|
      ingr = c.map(&:name).join(', ')
      recipe = Recipe.create name: 'Recipe name',
                             ingredients: ingr,
                             directions: ingr,
                             category: category,
                             user: user,
                             status: RecipeStatus::ACTIVE
      recipe.ingredients_list = c
    end
  end
end

User.where(is_admin: true).first_or_create(
  username: 'Default Admin',
  email: 'admin@admin.sabre',
  password: 'mustbechanged789',
  is_admin: true
)
