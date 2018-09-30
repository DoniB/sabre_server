require 'faker'

FactoryBot.define do
  
    factory :user do
        username { Faker::Name.name }
        email { Faker::Internet.unique.email }
        password { Faker::Internet.password }
    end

end
