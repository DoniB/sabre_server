# frozen_string_literal: true

require "rails_helper"
require "recipe_status"

RSpec.describe Api::V1::FavoritesController, type: :request do
  describe "GET #show" do
    it "returns true when exists" do
      favorite = create :favorite
      token = favorite.user.secure_tokens.create
      get "/api/v1/recipes/#{favorite.recipe_id}/favorite", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["favorite"]).to be_truthy
    end

    it "returns false when don't exists" do
      recipe = create :recipe, status: RecipeStatus::ACTIVE
      token = create(:user).secure_tokens.create
      get "/api/v1/recipes/#{recipe.id}/favorite", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["favorite"]).to be_falsey
    end

    it "returns false without token user" do
      favorite = create :favorite
      get "/api/v1/recipes/#{favorite.recipe_id}/favorite"
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["favorite"]).to be_falsey
    end

    it "returns false with unknown recipe" do
      token = create(:user).secure_tokens.create
      get "/api/v1/recipes/1/favorite", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["favorite"]).to be_falsey
    end
  end

  describe "DELETE #destroy" do
    it "should delete when exists" do
      favorite = create :favorite
      expect(Favorite.count).to eq(1)
      token = favorite.user.secure_tokens.create
      delete "/api/v1/recipes/#{favorite.recipe_id}/favorite", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["favorite"]).to be_falsey
      expect(Favorite.count).to eq(0)
    end

    it "should return false when don't exists" do
      recipe = create :recipe, status: RecipeStatus::ACTIVE
      token = create(:user).secure_tokens.create
      expect(Favorite.count).to eq(0)
      delete "/api/v1/recipes/#{recipe.id}/favorite", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["favorite"]).to be_falsey
      expect(Favorite.count).to eq(0)
    end

    it "returns false without token user" do
      favorite = create :favorite
      expect(Favorite.count).to eq(1)
      delete "/api/v1/recipes/#{favorite.recipe_id}/favorite"
      expect(response).to have_http_status(:success)
      expect(Favorite.count).to eq(1)
      expect(JSON.parse(response.body)["favorite"]).to be_falsey
    end

    it "returns false with unknown recipe" do
      token = create(:user).secure_tokens.create
      expect(Favorite.count).to eq(0)
      delete "/api/v1/recipes/1/favorite", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["favorite"]).to be_falsey
      expect(Favorite.count).to eq(0)
    end
  end

  describe "POST #create" do
    it "should create when it do not exists" do
      recipe = create :recipe, status: RecipeStatus::ACTIVE
      expect(Favorite.count).to eq(0)
      token = create(:user).secure_tokens.create
      post "/api/v1/recipes/#{recipe.id}/favorite", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["favorite"]).to be_truthy
      expect(Favorite.count).to eq(1)
    end

    it "should return true when it exists" do
      recipe = create :recipe, status: RecipeStatus::ACTIVE
      user = create(:user)
      create :favorite, recipe: recipe, user: user

      expect(Favorite.count).to eq(1)
      token = user.secure_tokens.create
      post "/api/v1/recipes/#{recipe.id}/favorite", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["favorite"]).to be_truthy
      expect(Favorite.count).to eq(1)
    end

    it "returns false without token user" do
      favorite = create :favorite
      expect(Favorite.count).to eq(1)
      post "/api/v1/recipes/#{favorite.recipe_id}/favorite"
      expect(response).to have_http_status(:success)
      expect(Favorite.count).to eq(1)
      expect(JSON.parse(response.body)["favorite"]).to be_falsey

      recipe = create :recipe
      post "/api/v1/recipes/#{recipe.id}/favorite"
      expect(response).to have_http_status(:success)
      expect(Favorite.count).to eq(1)
      expect(JSON.parse(response.body)["favorite"]).to be_falsey
    end

    it "returns false with unknown recipe" do
      token = create(:user).secure_tokens.create
      expect(Favorite.count).to eq(0)
      post "/api/v1/recipes/1000/favorite", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["favorite"]).to be_falsey
      expect(Favorite.count).to eq(0)
    end
  end
end
