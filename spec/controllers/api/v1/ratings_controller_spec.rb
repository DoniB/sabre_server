require 'rails_helper'

RSpec.describe Api::V1::RatingsController, type: :request do

  describe 'POST api/v1/recipes/:recipe_id/ratings#create' do

    it 'is valid with attributes' do
      user = create(:user)
      token = user.secure_tokens.create
      rating = build(:rating, user: user)

      expect(user.ratings.count).to eq(0)

      post "/api/v1/recipes/#{rating.recipe_id}/rating", { params: {stars: rating.stars}, headers: {
          'X-Secure-Token': token.token
      }}

      json = JSON.parse(response.body)
      expect(json['errors']).to be_nil
      expect(json['error']).to be_nil
      expect(response.status).to eq(201)
      expect(user.ratings.count).to eq(1)
    end

    it 'is invalid with nil stars' do
      user = create(:user)
      token = user.secure_tokens.create
      rating = build(:rating, stars: nil)

      expect(user.ratings.count).to eq(0)

      post "/api/v1/recipes/#{rating.recipe_id}/rating", { params: {stars: nil}, headers: {
          'X-Secure-Token': token.token
      }}

      json = JSON.parse(response.body)
      expect(json['errors']).to_not be_nil
      expect(json['error']).to be_nil
      expect(response.status).to eq(422)
      expect(user.ratings.count).to eq(0)
    end

    it 'is invalid with negative stars' do
      user = create(:user)
      token = user.secure_tokens.create
      rating = build(:rating, stars: -1)

      expect(user.ratings.count).to eq(0)

      post "/api/v1/recipes/#{rating.recipe_id}/rating", { params: {stars: -1}, headers: {
          'X-Secure-Token': token.token
      }}

      json = JSON.parse(response.body)
      expect(json['errors']).to_not be_nil
      expect(json['error']).to be_nil
      expect(response.status).to eq(422)
      expect(user.ratings.count).to eq(0)
    end

    it 'is invalid with stars greater than 5' do
      user = create(:user)
      token = user.secure_tokens.create
      rating = build(:rating, stars: 6)

      expect(user.ratings.count).to eq(0)

      post "/api/v1/recipes/#{rating.recipe_id}/rating", { params: {stars: 6}, headers: {
          'X-Secure-Token': token.token
      }}

      json = JSON.parse(response.body)
      expect(json['errors']).to_not be_nil
      expect(json['error']).to be_nil
      expect(response.status).to eq(422)
      expect(user.ratings.count).to eq(0)
    end

    it 'returns stars data' do
      user = create(:user)
      token = user.secure_tokens.create
      rating = build(:rating, user: user)

      expect(user.ratings.count).to eq(0)

      post "/api/v1/recipes/#{rating.recipe_id}/rating", { params: {stars: rating.stars}, headers: {
          'X-Secure-Token': token.token
      }}

      json = JSON.parse(response.body)
      expect(json['stars']).to eq(rating.stars)
      expect(json['user_id']).to eq(user.id)
      expect(json['recipe_id']).to eq(rating.recipe_id)
      expect(response.status).to eq(201)
      expect(user.ratings.count).to eq(1)
    end

    it 'should update if exists' do
      user = create(:user)
      token = user.secure_tokens.create
      rating = create(:rating, user: user, stars: 1)

      expect(user.ratings.count).to eq(1)

      post "/api/v1/recipes/#{rating.recipe_id}/rating", { params: {stars: 5}, headers: {
          'X-Secure-Token': token.token
      }}

      json = JSON.parse(response.body)
      expect(json['stars']).to eq(5)
      expect(json['user_id']).to eq(user.id)
      expect(json['recipe_id']).to eq(rating.recipe_id)
      expect(response.status).to eq(201)
      expect(user.ratings.count).to eq(1)
    end

    it 'update recipe average_stars' do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = create(:recipe)
      rating = build(:rating, user: user, recipe: recipe, stars: 4)

      expect(user.ratings.count).to eq(0)

      post "/api/v1/recipes/#{rating.recipe_id}/rating", { params: {stars: rating.stars}, headers: {
          'X-Secure-Token': token.token
      }}

      expect(user.ratings.count).to eq(1)
      expect(recipe.reload.average_stars).to eq(4)
    end

  end

  describe 'GET api/v1/recipes/:recipe_id/ratings#show' do

    it 'returns recipe rating' do
      rating = create(:rating)
      token = rating.user.secure_tokens.create

      expect(Recipe.count).to eq(1)
      expect(User.count).to eq(2)
      expect(Rating.count).to eq(1)

      get "/api/v1/recipes/#{rating.recipe_id}/rating", { params: {}, headers: { 'X-Secure-Token': token.token }}

      json = JSON.parse(response.body)
      expect(json['stars']).to eq(rating.stars)
      expect(json['recipe_id']).to eq(rating.recipe.id)
      expect(response.status).to eq(200)
      expect(json['user_id']).to eq(rating.user.id)
    end

    it 'should not return stars when invalid token' do
      rating = create(:rating)
      token = rating.user.secure_tokens.create

      expect(Recipe.count).to eq(1)
      expect(User.count).to eq(2)
      expect(Rating.count).to eq(1)

      get "/api/v1/recipes/#{rating.recipe_id}/rating", { params: {}, headers: { 'X-Secure-Token': "#{token.token}abc" }}

      json = JSON.parse(response.body)
      expect(json['stars']).to be_nil
      expect(json['recipe_id']).to be_nil
      expect(response.status).to eq(403)
      expect(json['user_id']).to be_nil
    end

    it 'should not return stars without token' do
      rating = create(:rating)

      expect(Recipe.count).to eq(1)
      expect(User.count).to eq(2)
      expect(Rating.count).to eq(1)

      get "/api/v1/recipes/#{rating.recipe_id}/rating"

      json = JSON.parse(response.body)
      expect(json['stars']).to be_nil
      expect(json['recipe_id']).to be_nil
      expect(response.status).to eq(403)
      expect(json['user_id']).to be_nil
    end

  end

end
