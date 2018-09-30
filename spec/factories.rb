require 'faker'

FactoryBot.define do
  factory :secure_token do
    user { create(:user) }
  end

  factory :user do
    username { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }
  end

end
