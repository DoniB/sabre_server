# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :ingredient do
    name { Faker::Food.ingredient }
  end

  factory :image do
    user { create :user }
    recipe { user.nil? ? create(:recipe) : create(:recipe, user: user) }
    file { ActionDispatch::Http::UploadedFile.new(
      tempfile: Rails.root.join("spec/files",
        %w(600x450.jpg 500x700.jpg 600x450.png 650x450.jpg 1200x900.jpg).sample),
      filename: %w(600x450.jpg 500x700.jpg 600x450.png 650x450.jpg 1200x900.jpg).sample) }
  end

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
