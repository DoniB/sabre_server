# frozen_string_literal: true

class Api::V1::IngredientsController < Api::V1::ApiController
  before_action :require_admin_authentication!, except: [:index, :show]
  before_action -> { @ingredient = Ingredient.find_by(id: params[:id]) }, only: [:update, :show]

  def index
    render json: get_ingredients
  end

  def create
    @ingredient = Ingredient.new name: params[:name]
    if @ingredient.save
      render json: @ingredient, status: :created
    else
      render json: { errors: @ingredient.errors },
             status: :unprocessable_entity
    end
  end

  def update
    if @ingredient.update(name: params[:name])
      render json: @ingredient
    else
      render json: { errors: @ingredient.errors },
             status: :unprocessable_entity
    end
  end

  def show
    render json: @ingredient
  end

  def destroy
    render json: {}
  end

  private
    def get_ingredients
      @ingredients = Ingredient.page(params[:page])
      filter_ingredients_by_query
      @ingredients
    end

    def filter_ingredients_by_query
      query = params[:q]
      @ingredients = @ingredients.search(query) if query
    end
end
