# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  it "has valid factory" do
    expect(create(:comment)).to be_valid
  end

  it "validates user_id presence" do
    comment = build(:comment, user: nil)
    expect(comment).to_not be_valid
  end

  it "validates recipe_id presence" do
    comment = build(:comment, recipe: nil)
    expect(comment).to_not be_valid
  end

  it "validates text presence" do
    comment = build(:comment, text: nil)
    expect(comment).to_not be_valid
  end

  it "validates text length" do
    comment = build(:comment, text: "123456789")
    expect(comment).to_not be_valid
    comment = build(:comment, text: "1234567890")
    expect(comment).to be_valid
  end

  it "has deleted by user" do
    admin = create(:admin)
    comment = create(:comment, deleted_by_user: admin)
    expect(comment.deleted_by_user).to eq(admin)
  end

  it "update deleted_at at deleted_by_user set" do
    admin = create(:admin)
    comment = create(:comment)
    expect(comment.deleted_by_user).to be_nil
    expect(comment.deleted_at).to be_nil
    comment.deleted_by_user = admin
    expect(comment.deleted_by_user).to eq(admin)
    expect(comment.deleted_at).to_not be_nil
    comment.reload
    expect(comment.deleted_by_user).to be_nil
    expect(comment.deleted_at).to be_nil
  end

  it "has soft delete" do
    admin = create(:admin)
    comment = create(:comment)
    expect(comment.deleted_by_user).to be_nil
    expect(comment.deleted_at).to be_nil
    comment.soft_delete admin
    expect(comment.deleted_by_user).to eq(admin)
    expect(comment.deleted_at).to_not be_nil
    comment.reload
    expect(comment.deleted_by_user).to eq(admin)
    expect(comment.deleted_at).to_not be_nil
  end

  it "it has active scope" do
    3.times { create :comment }
    expect(Comment.count).to eq(3)
    deleted = create(:comment, deleted_by_user: create(:admin))
    expect(Comment.count).to eq(4)
    expect(Comment.find_by_id deleted.id).to eq(deleted)
    expect(Comment.active.count).to eq(3)
    expect(Comment.active.find_by_id deleted.id).to be_nil
  end
end
