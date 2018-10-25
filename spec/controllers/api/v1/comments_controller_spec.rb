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

end
