# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CommentsController, type: :request do
  describe "POST api/v1/recipes/:recipe_id/comments#create" do
    it "is valid with attributes" do
      user = create(:user)
      token = user.secure_tokens.create
      comment = build(:comment)

      expect(user.comments.count).to eq(0)

      post "/api/v1/recipes/#{comment.recipe_id}/comments",  params: { text: comment.text }, headers: {
          'X-Secure-Token': token.token
      }

      json = JSON.parse(response.body)
      expect(json["errors"]).to be_nil
      expect(json["error"]).to be_nil
      expect(response.status).to eq(201)
      expect(user.comments.count).to eq(1)
    end

    it "is invalid with inactive user" do
      user = create(:user, active: false)
      token = user.secure_tokens.create
      comment = build(:comment)

      expect(user.comments.count).to eq(0)

      post "/api/v1/recipes/#{comment.recipe_id}/comments",  params: { text: comment.text }, headers: {
          'X-Secure-Token': token.token
      }

      json = JSON.parse(response.body)
      expect(json["errors"]).to be_nil
      expect(json["error"]).to eq("SecureToken invalid ou missing")
      expect(response.status).to eq(403)
      expect(user.comments.count).to eq(0)
    end

    it "is invalid with nil text" do
      user = create(:user)
      token = user.secure_tokens.create
      comment = build(:comment, text: nil)

      expect(user.comments.count).to eq(0)

      post "/api/v1/recipes/#{comment.recipe_id}/comments",  params: { text: comment.text }, headers: {
          'X-Secure-Token': token.token
      }

      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(json["error"]).to be_nil
      expect(response.status).to eq(422)
      expect(user.comments.count).to eq(0)
    end

    it "is invalid with text less then 10 characters" do
      user = create(:user)
      token = user.secure_tokens.create
      comment = build(:comment, text: "123456789")

      expect(user.comments.count).to eq(0)

      post "/api/v1/recipes/#{comment.recipe_id}/comments",  params: { text: comment.text }, headers: {
          'X-Secure-Token': token.token
      }

      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(json["error"]).to be_nil
      expect(response.status).to eq(422)
      expect(user.comments.count).to eq(0)
    end

    it "is invalid with wrong recipe id" do
      user = create(:user)
      token = user.secure_tokens.create
      comment = build(:comment)

      expect(user.comments.count).to eq(0)

      post "/api/v1/recipes/#{comment.recipe_id + 1}/comments",  params: { text: comment.text }, headers: {
          'X-Secure-Token': token.token
      }

      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(json["error"]).to be_nil
      expect(response.status).to eq(422)
      expect(user.comments.count).to eq(0)
    end

    it "returns comment data" do
      user = create(:user)
      token = user.secure_tokens.create
      comment = build(:comment)

      expect(user.comments.count).to eq(0)

      post "/api/v1/recipes/#{comment.recipe_id}/comments",  params: { text: comment.text }, headers: {
          'X-Secure-Token': token.token
      }

      json = JSON.parse(response.body)
      expect(json["text"]).to eq(comment.text)
      expect(json["user_id"]).to eq(user.id)
      expect(json["recipe_id"]).to eq(comment.recipe_id)
      expect(response.status).to eq(201)
      expect(user.comments.count).to eq(1)
    end
  end

  describe "GET api/v1/recipes/:recipe_id/comments#index" do
    it "returns recipe comments" do
      recipe = create(:recipe)
      comment = create(:comment, recipe: recipe)

      expect(recipe.comments.count).to eq(1)

      get "/api/v1/recipes/#{recipe.id}/comments"

      json = JSON.parse(response.body)
      expect(json[0]["text"]).to eq(comment.text)
      expect(json[0]["recipe_id"]).to eq(recipe.id)
      expect(response.status).to eq(200)
      expect(json[0]["text"]).to eq(comment.text)
      expect(json.size).to eq(1)

      create(:comment, recipe: recipe)
      get "/api/v1/recipes/#{recipe.id}/comments"
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end

    it "should returns empty json for no comment" do
      recipe = create(:recipe)

      expect(recipe.comments.count).to eq(0)

      get "/api/v1/recipes/#{recipe.id}/comments"

      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

    it "should not return other recipes comments" do
      recipe = create(:recipe)
      recipe2 = create(:recipe)
      create(:comment, recipe: recipe)

      expect(recipe.comments.count).to eq(1)
      expect(recipe2.comments.count).to eq(0)

      get "/api/v1/recipes/#{recipe2.id}/comments"

      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

    it "should not return soft deleted comments" do
      recipe = create(:recipe)
      3.times { create :comment, recipe: recipe }
      deleted = create(:comment, recipe: recipe, deleted_by_user: create(:admin))
      expect(Comment.count).to eq(4)

      get "/api/v1/recipes/#{recipe.id}/comments"
      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
      Comment.active.each { |c|
        expect(json).to include(JSON.parse(c.to_json))
      }
      expect(json).to_not include(JSON.parse(deleted.to_json))
    end
  end

  describe "DELETE api/v1/recipes/:recipe_id/:id/comments#destroy" do
    it "should be deleted by admin" do
      comment = create(:comment)
      recipe = comment.recipe
      admin = create(:admin)
      token = admin.secure_tokens.create

      delete "/api/v1/recipes/#{recipe.id}/comments/#{comment.id}", headers: {
          'X-Secure-Token': token.token }

      expect(comment.deleted_at).to be_nil
      expect(comment.deleted_by_user).to be_nil
      comment.reload
      expect(comment.deleted_at).to_not be_nil
      expect(comment.deleted_by_user).to eq(admin)
    end

    it "should not be deleted by user" do
      comment = create(:comment)
      recipe = comment.recipe
      user = create(:user)
      token = user.secure_tokens.create

      delete "/api/v1/recipes/#{recipe.id}/comments/#{comment.id}", headers: {
          'X-Secure-Token': token.token }

      expect(response.code).to eq("403")
      expect(comment.deleted_at).to be_nil
      expect(comment.deleted_by_user).to be_nil
      comment.reload
      expect(comment.deleted_at).to be_nil
      expect(comment.deleted_by_user).to be_nil
    end

    it "should not be deleted by visitor" do
      comment = create(:comment)
      recipe = comment.recipe

      delete "/api/v1/recipes/#{recipe.id}/comments/#{comment.id}"

      expect(response.code).to eq("403")
      expect(comment.deleted_at).to be_nil
      expect(comment.deleted_by_user).to be_nil
      comment.reload
      expect(comment.deleted_at).to be_nil
      expect(comment.deleted_by_user).to be_nil
    end
  end
end
