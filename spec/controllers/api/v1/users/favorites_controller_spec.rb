# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Users::FavoritesController, type: :request do
  describe "GET #index" do
    it "returns users favorites recipes" do
      user = create(:user)
      token = user.secure_tokens.create

      favorite = create :favorite, user: user
      expect(user.favorites.size).to eq(1)
      expect(user.recipes_favorites.size).to eq(1)
      get "/api/v1/users/favorites", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["id"]).to eq(favorite.recipe_id)

      9.times { create :favorite, user: user }
      expect(user.favorites.size).to eq(10)
      get "/api/v1/users/favorites", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.size).to eq(10)
    end

    it "returns empty json when user have no favorite" do
      user = create(:user)
      token = user.secure_tokens.create

      expect(user.favorites.size).to eq(0)
      expect(user.recipes_favorites.size).to eq(0)
      get "/api/v1/users/favorites", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)

      10.times { create :favorite }
      expect(user.favorites.size).to eq(0)
      expect(Favorite.count).to eq(10)
      get "/api/v1/users/favorites", headers: {
          'X-Secure-Token': token.token
      }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

    it "returns users empty json to visitors" do
      create :favorite
      expect(Favorite.count).to eq(1)
      get "/api/v1/users/favorites"
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)

      9.times { create :favorite }
      expect(Favorite.count).to eq(10)
      get "/api/v1/users/favorites"
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end
  end
end
