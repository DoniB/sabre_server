# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::IngredientsController, type: :controller do
  describe "GET api/v1/ingredients#index" do
    it "returns ingredients" do
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)

      ingredient = create :ingredient
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first["name"]).to eq(ingredient.name)
      expect(json.first["id"]).to eq(ingredient.id)

      4.times { create :ingredient }
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(5)
    end

    it "shoud paginate ingredients" do
      ingredient = create(:ingredient)
      19.times { create(:ingredient) }

      get :index, params: { page: 0 }
      json = JSON.parse(response.body)
      expect(json.last["id"]).to eq(ingredient.id)
      expect(json.size).to eq(20)
      ingredient2 = create(:ingredient)
      19.times { create(:ingredient) }

      get :index, params: { page: 1 }
      json = JSON.parse(response.body)
      expect(json.last["id"]).to eq(ingredient.id)
      expect(ingredient.id).to_not eq(ingredient2.id)
      expect(json.size).to eq(20)
      expect(Ingredient.count).to eq(40)

      get :index, params: { page: 0 }
      json = JSON.parse(response.body)
      expect(json.last["id"]).to eq(ingredient2.id)
    end

    it "shoud search for ingredients" do
      ingredient = create(:ingredient, name: "bananas")
      get :index, params: { q: "maçã" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)

      ingredient2 = create(:ingredient, name: "maçã")
      get :index, params: { q: "maçã" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["id"]).to eq(ingredient2.id)

      get :index, params: { q: "banana maçã" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      ids = json.map { |i| i["id"] }

      expect(ids).to include(ingredient.id)
      expect(ids).to include(ingredient2.id)
      expect(ids).to_not include(ingredient2.id + ingredient.id)

      ["pera", "uva", "ovo", "baunilha"].each { |n| create :ingredient, name: n }
      expect(Ingredient.count).to eq(6)

      get :index, params: { q: "banana" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["id"]).to eq(ingredient.id)

      expect(ingredient.id).to_not eq(ingredient2.id)
    end
  end

  describe "POST api/v1/ingredients#create" do
    it "shoud not create with visitor user" do
      ingredient = build :ingredient
      expect(Ingredient.count).to eq(0)
      post :create, params: ingredient.attributes
      json = JSON.parse(response.body)
      expect(Ingredient.count).to eq(0)
      expect(json["error"]).to_not be_nil
      expect(json["name"]).to be_nil
      expect(json["id"]).to be_nil
    end

    it "shoud no create with common user" do
      token = create(:user).secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      ingredient = build :ingredient
      expect(Ingredient.count).to eq(0)
      post :create, params: ingredient.attributes
      json = JSON.parse(response.body)
      expect(Ingredient.count).to eq(0)
      expect(json["error"]).to_not be_nil
      expect(json["name"]).to be_nil
      expect(json["id"]).to be_nil
    end

    it "shoud create whit admin user" do
      token = create(:admin).secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      ingredient = build :ingredient
      expect(Ingredient.count).to eq(0)
      post :create, params: ingredient.attributes
      json = JSON.parse(response.body)
      expect(Ingredient.count).to eq(1)
      expect(json["error"]).to be_nil
      expect(json["name"]).to eq(ingredient.name)
      expect(json["id"]).to_not be_nil
    end
  end

  describe "PATCH api/v1/ingredients#update" do
    it "should not update as visitor" do
      ingredient = create :ingredient
      expect(Ingredient.count).to eq(1)
      patch :update, params: { id: ingredient.id, name: ingredient.name + "updated" }
      json = JSON.parse(response.body)
      expect(Ingredient.count).to eq(1)
      expect(json["error"]).to_not be_nil
      expect(json["name"]).to be_nil
      expect(json["id"]).to be_nil
    end

    it "should not update as a normal user" do
      token = create(:user).secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      ingredient = create :ingredient
      expect(Ingredient.count).to eq(1)
      patch :update, params: { id: ingredient.id, name: ingredient.name + "updated" }
      json = JSON.parse(response.body)
      expect(Ingredient.count).to eq(1)
      expect(json["error"]).to_not be_nil
      expect(json["name"]).to be_nil
      expect(json["id"]).to be_nil
    end

    it "should update as an admin" do
      token = create(:admin).secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      ingredient = create :ingredient
      new_name = ingredient.name + "updated"
      expect(Ingredient.count).to eq(1)
      patch :update, params: { id: ingredient.id, name: new_name }
      json = JSON.parse(response.body)
      expect(Ingredient.count).to eq(1)
      expect(json["error"]).to be_nil
      expect(json["name"]).to_not be_nil
      expect(json["name"]).to_not eq(ingredient.name)
      expect(json["name"]).to eq(new_name)
      expect(json["id"]).to eq(ingredient.id)
    end
  end

  describe "GET api/v1/ingredients#show" do
    it "should returns the ingredient by id" do
      ingredient = create(:ingredient)
      get :show, params: { id: ingredient.id }
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(ingredient.id)
      expect(json["name"]).to eq(ingredient.name)
    end
  end

  describe "DELETE api/v1/ingredients#delete" do
    it "should not delete with visitor user" do
      expect(Ingredient.count).to eq(0)
      ingredient = create(:ingredient)
      expect(Ingredient.count).to eq(1)

      delete :destroy, params: { id: ingredient.id }
      expect(Ingredient.count).to eq(1)
      expect(response.code).to eq("403")
    end

    it "should not delete with common user" do
      token = create(:user).secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(Ingredient.count).to eq(0)
      ingredient = create(:ingredient)
      expect(Ingredient.count).to eq(1)

      delete :destroy, params: { id: ingredient.id }
      expect(Ingredient.count).to eq(1)
      expect(response.code).to eq("403")
    end

    it "should not delete with admin user" do
      token = create(:admin).secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(Ingredient.count).to eq(0)
      ingredient = create(:ingredient)
      expect(Ingredient.count).to eq(1)

      delete :destroy, params: { id: ingredient.id }
      expect(Ingredient.count).to eq(1)
      expect(response.code).to eq("200")
    end
  end
end
