class TownsController < ApplicationController
  before_action :set_town, only: %i[ show edit update destroy ]

  def index
    @towns = policy_scope(Town)
  end

  def show
  end

  def new
    @town = Town.new
    authorize @town
  end

  def edit
  end

  def create
    @town = Town.new(town_params)
    authorize @town

    if @town.save
      redirect_to @town, notice: "Town was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @town.update(town_params)
      redirect_to @town, notice: "Town was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @town.destroy
    redirect_to towns_url, notice: "Town was successfully destroyed."
  end

  private

  def set_town
    @town = Town.find(params[:id])
    authorize @town
  end

  def town_params
    params.require(:town).permit(:name, :description_ca, :description_es, :description_fr, :description_en, :region_id, photos: [])
  end
end
