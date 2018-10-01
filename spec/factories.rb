require 'faker'

FactoryBot.define do

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

end
