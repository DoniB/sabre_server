require 'rails_helper'

RSpec.describe Api::V1::CommentsController, type: :request do

  describe 'POST api/v1/recipes/:recipe_id/comments#create' do

    it 'is valid with attributes' do
      user = create(:user)
      token = user.secure_tokens.create
      comment = build(:comment)

      expect(user.comments.count).to eq(0)

      post "/api/v1/recipes/#{comment.recipe_id}/comments", { params: {text: comment.text}, headers: {
          'X-Secure-Token': token.token
      }}

      json = JSON.parse(response.body)
      expect(json['errors']).to be_nil
      expect(json['error']).to be_nil
      expect(response.status).to eq(201)
      expect(user.comments.count).to eq(1)
    end

    it 'is invalid with nil text' do
      user = create(:user)
      token = user.secure_tokens.create
      comment = build(:comment, text: nil)

      expect(user.comments.count).to eq(0)

      post "/api/v1/recipes/#{comment.recipe_id}/comments", { params: {text: comment.text}, headers: {
          'X-Secure-Token': token.token
      }}

      json = JSON.parse(response.body)
      expect(json['errors']).to_not be_nil
      expect(json['error']).to be_nil
      expect(response.status).to eq(422)
      expect(user.comments.count).to eq(0)
    end

    it 'is invalid with text less then 10 characters' do
      user = create(:user)
      token = user.secure_tokens.create
      comment = build(:comment, text: '123456789')

      expect(user.comments.count).to eq(0)

      post "/api/v1/recipes/#{comment.recipe_id}/comments", { params: {text: comment.text}, headers: {
          'X-Secure-Token': token.token
      }}

      json = JSON.parse(response.body)
      expect(json['errors']).to_not be_nil
      expect(json['error']).to be_nil
      expect(response.status).to eq(422)
      expect(user.comments.count).to eq(0)
    end

    it 'is invalid with wrong recipe id' do
      user = create(:user)
      token = user.secure_tokens.create
      comment = build(:comment)

      expect(user.comments.count).to eq(0)

      post "/api/v1/recipes/#{comment.recipe_id + 1}/comments", { params: {text: comment.text}, headers: {
          'X-Secure-Token': token.token
      }}

      json = JSON.parse(response.body)
      expect(json['errors']).to_not be_nil
      expect(json['error']).to be_nil
      expect(response.status).to eq(422)
      expect(user.comments.count).to eq(0)
    end

    it 'returns comment data' do
      user = create(:user)
      token = user.secure_tokens.create
      comment = build(:comment)

      expect(user.comments.count).to eq(0)

      post "/api/v1/recipes/#{comment.recipe_id}/comments", { params: {text: comment.text}, headers: {
          'X-Secure-Token': token.token
      }}

      json = JSON.parse(response.body)
      expect(json['text']).to eq(comment.text)
      expect(json['user_id']).to eq(user.id)
      expect(json['recipe_id']).to eq(comment.recipe_id)
      expect(response.status).to eq(201)
      expect(user.comments.count).to eq(1)
    end

  end

  describe 'GET api/v1/recipes/:recipe_id/comments#index' do

    it 'returns recipe comments' do
      recipe = create(:recipe)
      comment = create(:comment, recipe: recipe)

      expect(recipe.comments.count).to eq(1)

      get "/api/v1/recipes/#{recipe.id}/comments"

      json = JSON.parse(response.body)
      expect(json[0]['text']).to eq(comment.text)
      expect(json[0]['recipe_id']).to eq(recipe.id)
      expect(response.status).to eq(200)
      expect(json[0]['text']).to eq(comment.text)
      expect(json.size).to eq(1)

      create(:comment, recipe: recipe)
      get "/api/v1/recipes/#{recipe.id}/comments"
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end

    it 'should returns empty json for no comment' do
      recipe = create(:recipe)

      expect(recipe.comments.count).to eq(0)

      get "/api/v1/recipes/#{recipe.id}/comments"

      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

    it 'should not return other recipes comments' do
      recipe = create(:recipe)
      recipe2 = create(:recipe)
      create(:comment, recipe: recipe)

      expect(recipe.comments.count).to eq(1)
      expect(recipe2.comments.count).to eq(0)

      get "/api/v1/recipes/#{recipe2.id}/comments"

      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

  end

end
