require 'faker'

FactoryBot.define do

  factory :comment do
    text { Faker::GameOfThrones.quote }
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
