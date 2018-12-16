# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CategoriesController, type: :controller do
  describe "GET #index" do
    it "returns all categories" do
      get :index
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json.size).to eq(0)

      category = create(:category)
      get :index
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json.size).to eq(1)
      expect(json[0]["id"]).to eq(category.id)
      expect(json[0]["name"]).to eq(category.name)

      4.times { create(:category) }
      get :index
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json.size).to eq(5)
    end
  end
end
