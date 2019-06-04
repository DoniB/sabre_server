# frozen_string_literal: true

class Api::V1::CategoriesController < Api::V1::ApiController
  before_action :require_admin_authentication!, only: %i[create update]
  before_action -> { @category = Category.find_by id: params[:id] }, only: [:update]

  def index
    render json: Category.all
  end

  def create
    category = Category.new name: params[:name]

    if category.save
      render json: category, status: :created
    else
      render json: { errors: category.errors },
             status: :unprocessable_entity
    end
  end

  def update
    if @category.update(name: params[:name])
      render json: @category
    else
      render json: { errors: @category.errors },
             status: :unprocessable_entity
    end
  end
end
