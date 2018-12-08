# frozen_string_literal: true

require "rails_helper"
require "recipe_status"

RSpec.describe Api::V1::Users::RecipeController, type: :controller do
  describe "POST api/v1/users/recipe#create" do
    it "is valid with attributes" do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = build(:recipe)

      request.headers["X-Secure-Token"] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json["errors"]).to be_nil
      expect(json["error"]).to be_nil
      expect(response.status).to eq(201)
      expect(Recipe.find_by name: recipe.name).to_not be_nil
      expect(user.recipes.count).to eq(1)
    end

    it "should not set average_stars" do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = build(:recipe, average_stars: 5)

      request.headers["X-Secure-Token"] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json["average_stars"]).to eq(0)
    end

    it "create with WAITING_ACTIVATION status by default" do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = build(:recipe)

      request.headers["X-Secure-Token"] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json["status"]).to eq(RecipeStatus::WAITING_ACTIVATION)
      expect(Recipe.find_by(name: recipe.name).status).to eq(RecipeStatus::WAITING_ACTIVATION)
    end

    it "is not valid without name attribute" do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = build(:recipe, name: nil)

      request.headers["X-Secure-Token"] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(response.status).to eq(422)
      expect(user.recipes.count).to eq(0)
    end

    it "is not valid without ingredients attribute" do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = build(:recipe, ingredients: nil)

      request.headers["X-Secure-Token"] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(response.status).to eq(422)
      expect(Recipe.find_by name: recipe.name).to be_nil
      expect(user.recipes.count).to eq(0)
    end

    it "is not valid without directions attribute" do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = build(:recipe, directions: nil)

      request.headers["X-Secure-Token"] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(response.status).to eq(422)
      expect(Recipe.find_by name: recipe.name).to be_nil
      expect(user.recipes.count).to eq(0)
    end

    it "is not valid without secure token" do
      user = create(:user)
      recipe = build(:recipe)

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json["error"]).to_not be_nil
      expect(json["errors"]).to be_nil
      expect(response.status).to eq(403)
      expect(Recipe.find_by name: recipe.name).to be_nil
      expect(user.recipes.count).to eq(0)
    end

    it "is not valid with an expired secure token" do
      user = create(:user)
      recipe = build(:recipe)
      token = user.secure_tokens.create expires: 1.minute.ago
      request.headers["X-Secure-Token"] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json["error"]).to_not be_nil
      expect(json["errors"]).to be_nil
      expect(response.status).to eq(403)
      expect(Recipe.find_by name: recipe.name).to be_nil
      expect(user.recipes.count).to eq(0)
    end
  end

  describe "PATCH api/v1/users/recipe#update" do
    it "should update ingredients" do
      recipe = create(:recipe)
      token = recipe.user.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      ingredients = "Updated " + recipe.ingredients
      patch :update, params: { id: recipe.id, ingredients: ingredients }

      json = JSON.parse(response.body)

      expect(json["ingredients"]).to eq(ingredients)
      expect(response.status).to eq(202)
      expect(Recipe.find(recipe.id).ingredients).to eq(ingredients)
    end

    it "should not change average_stars" do
      recipe = create(:recipe, average_stars: 5)
      token = recipe.user.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      ingredients = "Updated " + recipe.ingredients
      patch :update, params: { id: recipe.id, ingredients: ingredients, average_stars: 4 }

      json = JSON.parse(response.body)

      expect(json["average_stars"]).to_not eq(4)
      expect(json["average_stars"]).to eq(5)
      expect(response.status).to eq(202)
    end

    it "should not update another user recipe" do
      recipe = create(:recipe)
      token = create(:user).secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      ingredients = "Updated " + recipe.ingredients
      patch :update, params: { id: recipe.id, ingredients: ingredients }

      json = JSON.parse(response.body)

      expect(json["ingredients"]).to_not eq(ingredients)
      expect(response.status).to eq(403)
      expect(Recipe.find(recipe.id).ingredients).to_not eq(ingredients)
    end

    it "should update name" do
      recipe = create(:recipe)
      token = recipe.user.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      name = "Updated " + recipe.name
      patch :update, params: { id: recipe.id, name: name }

      json = JSON.parse(response.body)

      expect(json["name"]).to eq(name)
      expect(response.status).to eq(202)
      expect(Recipe.find(recipe.id).name).to eq(name)
    end

    it "should update directions" do
      recipe = create(:recipe)
      token = recipe.user.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      directions = "Updated " + recipe.directions
      patch :update, params: { id: recipe.id, directions: directions }

      json = JSON.parse(response.body)

      expect(json["directions"]).to eq(directions)
      expect(response.status).to eq(202)
      expect(Recipe.find(recipe.id).directions).to eq(directions)
    end

    it "should not update status to ACTIVE whit normal user" do
      recipe = create(:recipe)
      token = recipe.user.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      patch :update, params: { id: recipe.id, status: RecipeStatus::ACTIVE }

      json = JSON.parse(response.body)

      expect(json["status"]).to_not eq(RecipeStatus::ACTIVE)
      expect(json["status"]).to eq(RecipeStatus::WAITING_ACTIVATION)
      expect(response.status).to eq(202)
      expect(Recipe.find(recipe.id).status).to_not eq(RecipeStatus::ACTIVE)
    end

    it "should update status to ACTIVE whit admin user" do
      recipe = create(:recipe)
      user = recipe.user
      token = user.secure_tokens.create
      user.is_admin = true
      user.save

      request.headers["X-Secure-Token"] = token.token

      patch :update, params: { id: recipe.id, status: RecipeStatus::ACTIVE }

      json = JSON.parse(response.body)

      expect(json["status"]).to eq(RecipeStatus::ACTIVE)
      expect(response.status).to eq(202)
      expect(Recipe.find(recipe.id).status).to eq(RecipeStatus::ACTIVE)
    end
  end

  describe "GET api/v1/users/recipe#index" do
    it "should returns the user`s recipes" do
      user = create(:user)
      token = user.secure_tokens.create
      4.times { create(:recipe, user: user) }
      expect(user.recipes.count).to eq(4)

      request.headers["X-Secure-Token"] = token.token

      get :index

      json = JSON.parse(response.body)
      expect(json.size).to eq(4)
      json.each do |i|
        expect(i["user_id"]).to eq(user.id)
      end
      expect(response.status).to eq(200)
    end

    it "should search the user`s recipes" do
      user = create(:user)
      token = user.secure_tokens.create
      4.times { create(:recipe, user: user) }
      recipe = create(:recipe, user: user, name: "abcdefghijklm")
      expect(user.recipes.count).to eq(5)

      request.headers["X-Secure-Token"] = token.token

      get :index, params: { q: recipe.name }

      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["user_id"]).to eq(user.id)
      expect(response.status).to eq(200)
    end

    it "should not return another user`s recipes" do
      user = create(:user)
      token = user.secure_tokens.create
      4.times { create(:recipe) }
      expect(user.recipes.count).to eq(0)
      expect(Recipe.count).to eq(4)

      request.headers["X-Secure-Token"] = token.token

      get :index

      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
      expect(response.status).to eq(200)
    end

    it "should not return another user`s recipes waiting activation when not admin" do
      user = create(:user)
      token = user.secure_tokens.create
      4.times { create(:recipe, status: RecipeStatus::WAITING_ACTIVATION) }
      expect(user.recipes.count).to eq(0)
      expect(Recipe.count).to eq(4)

      request.headers["X-Secure-Token"] = token.token

      get :index, params: { status: "waiting_activation" }

      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
      expect(response.status).to eq(200)
    end

    it "should return another user recipes waiting activation when admin" do
      user = create(:admin)
      token = user.secure_tokens.create
      4.times { create(:recipe, status: RecipeStatus::WAITING_ACTIVATION) }
      expect(user.recipes.count).to eq(0)
      expect(Recipe.count).to eq(4)

      request.headers["X-Secure-Token"] = token.token

      get :index, params: { status: "waiting_activation",
                            all_users: 1 }

      json = JSON.parse(response.body)
      expect(json.size).to eq(4)
      expect(response.status).to eq(200)
    end

    it "should filter waiting activation when admin" do
      user = create(:admin)
      token = user.secure_tokens.create
      4.times { create(:recipe, status: RecipeStatus::WAITING_ACTIVATION) }
      3.times { create(:recipe, status: RecipeStatus::WAITING_ACTIVATION, user: user) }
      2.times { create(:recipe, status: RecipeStatus::ACTIVE, user: user) }
      expect(user.recipes.count).to eq(5)
      expect(Recipe.count).to eq(9)

      request.headers["X-Secure-Token"] = token.token

      get :index, params: { status: "waiting_activation" }

      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
      expect(response.status).to eq(200)
    end

    it "should search all users recipes when admin" do
      user = create(:admin)
      token = user.secure_tokens.create
      4.times { create(:recipe, status: RecipeStatus::ACTIVE) }
      2.times { create(:recipe, status: RecipeStatus::ACTIVE, user: user) }

      recipe = create(:recipe, name: "abcdefghijklm")
      expect(user.recipes.count).to eq(2)

      request.headers["X-Secure-Token"] = token.token

      get :index, params: { q: recipe.name, all_users: 1 }

      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["user_id"]).to_not eq(user.id)
      expect(json[0]["user_id"]).to eq(recipe.user_id)
      expect(response.status).to eq(200)
    end
  end

  describe "GET api/v2/users/recipe#show" do
    it "should returns the user`s recipes" do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = create(:recipe, user: user)
      expect(user.recipes.count).to eq(1)

      request.headers["X-Secure-Token"] = token.token

      get :show, params: { id: recipe.id }

      json = JSON.parse(response.body)
      expect(json["user_id"]).to eq(user.id)
      expect(json["name"]).to eq(recipe.name)
      expect(json["ingredients"]).to eq(recipe.ingredients)
      expect(json["directions"]).to eq(recipe.directions)
      expect(json["status"]).to eq(recipe.status)
      expect(response.status).to eq(200)
    end

    it "should not return another user`s recipes" do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = create(:recipe, status: RecipeStatus::ACTIVE)
      expect(user.recipes.count).to eq(0)
      expect(Recipe.count).to eq(1)

      request.headers["X-Secure-Token"] = token.token

      get :show, params: { id: recipe.id }

      json = JSON.parse(response.body)
      expect(json["user_id"]).to be_nil
      expect(json["name"]).to be_nil
      expect(json["ingredients"]).to be_nil
      expect(json["directions"]).to be_nil
      expect(json["status"]).to be_nil
      expect(response.status).to eq(403)
    end

    it "should not return another user`s recipes waiting activation when not admin" do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = create(:recipe, status: RecipeStatus::WAITING_ACTIVATION)
      expect(user.recipes.count).to eq(0)
      expect(Recipe.count).to eq(1)

      request.headers["X-Secure-Token"] = token.token

      get :show, params: { id: recipe.id }

      json = JSON.parse(response.body)
      expect(json["user_id"]).to be_nil
      expect(json["name"]).to be_nil
      expect(json["ingredients"]).to be_nil
      expect(json["directions"]).to be_nil
      expect(json["status"]).to be_nil
      expect(response.status).to eq(403)
    end

    it "should return another user recipes waiting activation when admin" do
      user = create(:admin)
      token = user.secure_tokens.create
      recipe = create(:recipe)
      expect(user.recipes.count).to eq(0)

      request.headers["X-Secure-Token"] = token.token

      get :show, params: { id: recipe.id }

      json = JSON.parse(response.body)
      expect(json["user_id"]).to_not eq(user.id)
      expect(json["name"]).to eq(recipe.name)
      expect(json["ingredients"]).to eq(recipe.ingredients)
      expect(json["directions"]).to eq(recipe.directions)
      expect(json["status"]).to eq(recipe.status)
      expect(response.status).to eq(200)
    end
  end
end
