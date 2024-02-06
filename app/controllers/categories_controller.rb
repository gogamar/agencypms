class CategoriesController < ApplicationController
  before_action :set_category, only: %i[ edit update destroy ]

  def index
    @categories = policy_scope(Category)
  end

  def new
    @category = Category.new
    authorize @category
  end

  def edit
  end

  def create
    @category = Category.new(category_params)
    authorize @category

    if @category.save
      redirect_to new_category_post_path(@category), notice: "Category was successfully created. Now you can add a post."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      redirect_to new_category_post_path(@category), notice: "Category was successfully updated. Now you can add a post."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_url, notice: "Category was successfully destroyed."
  end

  private

  def set_category
    @category = Category.find(params[:id])
    authorize @category
  end

  def category_params
    params.require(:category).permit(:name_ca, :name_es, :name_en, :name_fr)
  end
end
