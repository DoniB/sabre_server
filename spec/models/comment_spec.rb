require 'rails_helper'

RSpec.describe Comment, type: :model do

  it 'has valid factory' do
    expect(create(:comment)).to be_valid
  end

  it 'validates user_id presence' do
    comment = build(:comment, user: nil)
    expect(comment).to_not be_valid
  end

  it 'validates recipe_id presence' do
    comment = build(:comment, recipe: nil)
    expect(comment).to_not be_valid
  end

  it 'validates text presence' do
    comment = build(:comment, text: nil)
    expect(comment).to_not be_valid
  end

  it 'validates text length' do
    comment = build(:comment, text: '123456789')
    expect(comment).to_not be_valid
    comment = build(:comment, text: '1234567890')
    expect(comment).to be_valid
  end

end
