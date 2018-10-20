require 'rails_helper'
require 'recipe_status'

RSpec.describe Api::V1::RecipesController, type: :controller do

  describe 'GET api/v1/recipes#index' do

    it 'should send an empty json without an active recipes' do
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

    it 'should send active recipes' do
      3.times { create :recipe, status: RecipeStatus::ACTIVE }
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
      expect(Recipe.active.first.name).to eq(json[0]['name'])
    end

    it 'should not send paused recipes' do
      3.times { create :recipe, status: RecipeStatus::PAUSED }
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

    it 'should not send rejected recipes' do
      3.times { create :recipe, status: RecipeStatus::REJECTED }
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

    it 'should not send recipes waiting activation' do
      3.times { create :recipe, status: RecipeStatus::WAITING_ACTIVATION }
      get :index
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end

  end

end
