class RegionsController < ApplicationController
  before_action :set_region, only: %i[ show edit update destroy ]

  def index
    @regions = policy_scope(Region)
  end

  def show
  end

  def new
    @region = Region.new
    authorize @region
  end

  def edit
  end

  def create
    @region = Region.new(region_params)
    authorize @region

    if @region.save
      redirect_to @region, notice: "Region was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @region.update(region_params)
      redirect_to @region, notice: "Region was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @region.destroy
    redirect_to regions_url, notice: "Region was successfully destroyed."
  end

  private

  def set_region
    @region = Region.find(params[:id])
    authorize @region
  end

  def region_params
    params.require(:region).permit(:name_ca, :name_es, :name_fr, :name_en, :description_ca, :description_es, :description_fr, :description_en, photos: [])
  end
end
