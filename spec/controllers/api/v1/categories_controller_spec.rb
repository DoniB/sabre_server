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

  describe "POST #create" do
    it "Should create a category" do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(Category.count).to eq(0)

      name = "My new admin category"

      post :create, params: { name: name }
      json = JSON.parse(response.body)
      expect(Category.count).to eq(1)
      expect(json["error"]).to be_nil
      expect(json["errors"]).to be_nil
      expect(json["name"]).to eq(name)
      expect(json["id"]).to_not be_nil
    end

    it "Should NOT create a category as normal user" do
      user = create(:user)
      token = user.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(Category.count).to eq(0)

      name = "My new user category"

      post :create, params: { name: name }
      json = JSON.parse(response.body)
      expect(Category.count).to eq(0)
      expect(json["error"]).to eq("Forbidden")
      expect(json["name"]).to be_nil
      expect(json["id"]).to be_nil
    end

    it "Should NOT create a category as visitor" do
      expect(Category.count).to eq(0)

      name = "My new visitor category"

      post :create, params: { name: name }
      json = JSON.parse(response.body)
      expect(Category.count).to eq(0)
      expect(json["error"]).to eq("SecureToken invalid ou missing")
      expect(json["name"]).to be_nil
      expect(json["id"]).to be_nil
    end
  end

  describe "PATCH #update" do
    it "Should update a category" do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      category = Category.create name: "old name"

      expect(Category.count).to eq(1)

      name = "My new admin category name"

      patch :update, params: { name: name, id: category.id }
      json = JSON.parse(response.body)
      expect(Category.count).to eq(1)
      expect(json["error"]).to be_nil
      expect(json["errors"]).to be_nil
      expect(json["name"]).to eq(name)
      expect(json["id"]).to eq(category.id)
    end

    it "Should NOT update a category as normal user" do
      user = create(:user)
      token = user.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      category = Category.create name: "old name"

      expect(Category.count).to eq(1)

      name = "My new user category name"

      patch :update, params: { name: name, id: category.id }
      json = JSON.parse(response.body)
      expect(Category.count).to eq(1)
      expect(json["error"]).to eq("Forbidden")
      expect(Category.first.name).to_not eq(name)
    end

    it "Should NOT create a category as visitor" do
      expect(Category.count).to eq(0)

      name = "My new visitor category"

      category = Category.create name: "old name"

      expect(Category.count).to eq(1)

      name = "My new visitor category name"

      patch :update, params: { name: name, id: category.id }
      json = JSON.parse(response.body)
      expect(Category.count).to eq(1)
      expect(json["error"]).to eq("SecureToken invalid ou missing")
      expect(Category.first.name).to_not eq(name)
    end
  end
end
