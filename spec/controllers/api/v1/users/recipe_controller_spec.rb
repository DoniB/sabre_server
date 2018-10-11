require 'rails_helper'
require 'recipe_status'

RSpec.describe Api::V1::Users::RecipeController, type: :controller do

  describe 'POST api/v1/users/recipe#create' do

    it 'is valid with attributes' do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = build(:recipe)

      request.headers['X-Secure-Token'] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json['errors']).to be_nil
      expect(json['error']).to be_nil
      expect(response.status).to eq(201)
      expect(Recipe.find_by name: recipe.name).to_not be_nil
      expect(user.recipes.count).to eq(1)
    end

    it 'create with WAITING_ACTIVATION status by default' do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = build(:recipe)

      request.headers['X-Secure-Token'] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json['status']).to eq(RecipeStatus::WAITING_ACTIVATION)
      expect(Recipe.find_by(name: recipe.name).status).to eq(RecipeStatus::WAITING_ACTIVATION)
    end

    it 'is not valid without name attribute' do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = build(:recipe, name: nil)

      request.headers['X-Secure-Token'] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json['errors']).to_not be_nil
      expect(response.status).to eq(422)
      expect(user.recipes.count).to eq(0)
    end

    it 'is not valid without ingredients attribute' do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = build(:recipe, ingredients: nil)

      request.headers['X-Secure-Token'] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json['errors']).to_not be_nil
      expect(response.status).to eq(422)
      expect(Recipe.find_by name: recipe.name).to be_nil
      expect(user.recipes.count).to eq(0)
    end

    it 'is not valid without directions attribute' do
      user = create(:user)
      token = user.secure_tokens.create
      recipe = build(:recipe, directions: nil)

      request.headers['X-Secure-Token'] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json['errors']).to_not be_nil
      expect(response.status).to eq(422)
      expect(Recipe.find_by name: recipe.name).to be_nil
      expect(user.recipes.count).to eq(0)
    end

    it 'is not valid without secure token' do
      user = create(:user)
      recipe = build(:recipe)

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json['error']).to_not be_nil
      expect(json['errors']).to be_nil
      expect(response.status).to eq(403)
      expect(Recipe.find_by name: recipe.name).to be_nil
      expect(user.recipes.count).to eq(0)
    end

    it 'is not valid with an expired secure token' do
      user = create(:user)
      recipe = build(:recipe)
      token = user.secure_tokens.create expires: 1.minute.ago
      request.headers['X-Secure-Token'] = token.token

      post :create, params: recipe.attributes

      json = JSON.parse(response.body)
      expect(json['error']).to_not be_nil
      expect(json['errors']).to be_nil
      expect(response.status).to eq(403)
      expect(Recipe.find_by name: recipe.name).to be_nil
      expect(user.recipes.count).to eq(0)
    end

  end

end
