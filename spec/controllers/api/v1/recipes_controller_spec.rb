# frozen_string_literal: true

require "rails_helper"
require "recipe_status"

RSpec.describe Api::V1::RecipesController, type: :controller do
  describe "GET api/v1/recipes#index" do
    it "should send an empty json without an active recipes" do
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

    it "should send active recipes" do
      3.times { create :recipe, status: RecipeStatus::ACTIVE }
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
      expect(Recipe.active.first.name).to eq(json[0]["name"])
    end

    it "should not send paused recipes" do
      3.times { create :recipe, status: RecipeStatus::PAUSED }
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

    it "should not send rejected recipes" do
      3.times { create :recipe, status: RecipeStatus::REJECTED }
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

    it "should not send recipes waiting activation" do
      3.times { create :recipe, status: RecipeStatus::WAITING_ACTIVATION }
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

    it "is paginated" do
      recipe = create(:recipe, status: RecipeStatus::ACTIVE)
      19.times { create(:recipe, user: recipe.user, status: RecipeStatus::ACTIVE) }

      get :index, params: { page: 0 }
      json = JSON.parse(response.body)
      expect(json.last["id"]).to eq(recipe.id)
      expect(json.size).to eq(20)
      recipe2 = create(:recipe, status: RecipeStatus::ACTIVE)
      19.times { create(:recipe, user: recipe.user, status: RecipeStatus::ACTIVE) }

      get :index, params: { page: 1 }
      json = JSON.parse(response.body)
      expect(json.last["id"]).to eq(recipe.id)
      expect(recipe.id).to_not eq(recipe2.id)
      expect(json.size).to eq(20)
      expect(Recipe.count).to eq(40)

      get :index, params: { page: 0 }
      json = JSON.parse(response.body)
      expect(json.last["id"]).to eq(recipe2.id)
    end

    it "has default value paginated" do
      recipe = create(:recipe, status: RecipeStatus::ACTIVE)
      19.times { create(:recipe, user: recipe.user, status: RecipeStatus::ACTIVE) }

      get :index
      json = JSON.parse(response.body)
      expect(json.last["id"]).to eq(recipe.id)
      expect(json.size).to eq(20)
      recipe2 = create(:recipe, status: RecipeStatus::ACTIVE)
      19.times { create(:recipe, user: recipe.user, status: RecipeStatus::ACTIVE) }

      get :index, params: { page: 1 }
      json = JSON.parse(response.body)
      expect(json.last["id"]).to eq(recipe.id)
      expect(recipe.id).to_not eq(recipe2.id)
      expect(json.size).to eq(20)
      expect(Recipe.count).to eq(40)

      get :index
      json = JSON.parse(response.body)
      expect(json.last["id"]).to eq(recipe2.id)
    end

    it "has filters result by category" do
      category = create(:category)
      category2 = create(:category)

      recipe = create(:recipe, status: RecipeStatus::ACTIVE, category: category)

      get :index, params: { category: category.id }
      json = JSON.parse(response.body)
      expect(json.first["id"]).to eq(recipe.id)
      expect(json.size).to eq(1)

      recipe2 = create(:recipe, status: RecipeStatus::ACTIVE, category: category)
      get :index, params: { category: category.id }
      json = JSON.parse(response.body)
      expect(json.last["id"]).to eq(recipe.id)
      expect(json.first["id"]).to eq(recipe2.id)
      expect(recipe.id).to_not eq(recipe2.id)
      expect(json.size).to eq(2)
      expect(Recipe.count).to eq(2)

      create(:recipe, status: RecipeStatus::ACTIVE, category: category2)
      get :index, params: { category: category.id }
      json = JSON.parse(response.body)
      expect(json.last["id"]).to eq(recipe.id)
      expect(json.first["id"]).to eq(recipe2.id)
      expect(recipe.id).to_not eq(recipe2.id)
      expect(json.size).to eq(2)
      expect(Recipe.count).to eq(3)
    end

    it "filter recipes by query" do
      recipe = create(:recipe, status: RecipeStatus::ACTIVE, name: "receitas caseiras", ingredients: "bananas maçãs")
      get :index, params: { q: "receita" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["id"]).to eq(recipe.id)

      recipe2 = create(:recipe, status: RecipeStatus::ACTIVE, name: "receita caseira", ingredients: "uvas peras")
      get :index, params: { q: "receita" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json[1]["id"]).to eq(recipe.id)
      expect(json[0]["id"]).to eq(recipe2.id)

      get :index, params: { q: "receitas" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json[1]["id"]).to eq(recipe.id)
      expect(json[0]["id"]).to eq(recipe2.id)

      get :index, params: { q: "banana" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["id"]).to eq(recipe.id)

      expect(recipe.id).to_not eq(recipe2.id)
    end
  end

  describe "GET api/v1/recipes#show" do
    it "returns active recipes" do
      recipe = create(:recipe, status: RecipeStatus::ACTIVE)
      get :show, params: { id: recipe.id }
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(recipe.id)

      recipe2 = create(:recipe, status: RecipeStatus::ACTIVE)
      get :show, params: { id: recipe2.id }
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(recipe2.id)

      expect(recipe.id).to_not eq(recipe2.id)
    end

    it "returns average_stars" do
      recipe = create(:recipe, status: RecipeStatus::ACTIVE)
      get :show, params: { id: recipe.id }
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(recipe.id)
      expect(json["average_stars"]).to eq(0)

      recipe = create(:recipe, status: RecipeStatus::ACTIVE, average_stars: 5)
      get :show, params: { id: recipe.id }
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(recipe.id)
      expect(json["average_stars"]).to eq(5)
    end

    it "do not returns recipes waiting activation" do
      recipe = create(:recipe, status: RecipeStatus::WAITING_ACTIVATION)
      get :show, params: { id: recipe.id }
      json = JSON.parse(response.body)
      expect(json.empty?).to be_truthy
      expect(response.status).to eq(404)

      recipe2 = create(:recipe, status: RecipeStatus::WAITING_ACTIVATION)
      get :show, params: { id: recipe2.id }
      json = JSON.parse(response.body)
      expect(json.empty?).to be_truthy
      expect(response.status).to eq(404)

      expect(recipe.id).to_not eq(recipe2.id)
    end

    it "do not returns any recipe when an invalid id is requested" do
      get :show, params: { id: 0 }
      json = JSON.parse(response.body)
      expect(json.empty?).to be_truthy
      expect(response.status).to eq(404)

      recipe = create(:recipe, status: RecipeStatus::ACTIVE)
      get :show, params: { id: recipe.id + 1 }
      json = JSON.parse(response.body)
      expect(json.empty?).to be_truthy
      expect(response.status).to eq(404)
    end
  end
end
