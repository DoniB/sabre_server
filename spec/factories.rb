# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :favorite do
    user { create :user }
    recipe { create :recipe }
  end

  factory :category do
    name { Faker::Book.genre }
  end

  factory :rating do
    stars { Faker::Number.between 0, 5 }
    user  { create(:user) }
    recipe { create(:recipe) }
  end

  factory :comment do
    text { Faker::TvShows::GameOfThrones.quote }
    user { create(:user) }
    recipe { create(:recipe) }
  end

  factory :recipe do
    name { Faker::Food.dish }
    ingredients { Faker::Food.ingredient + "\n" +
                  Faker::Food.ingredient + "\n" +
                  Faker::Food.ingredient + "\n" +
                  Faker::Food.ingredient + "\n"}
    directions { Faker::Food.description }
    user { create(:user) }
    category { Category.count == 0 ? create(:category) : Category.all.sample }
  end

  factory :secure_token do
    user { create(:user) }
  end

  factory :user do
    username { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }
  end

  factory :admin, class: User do
    username { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }
    is_admin { true }
  end
end
