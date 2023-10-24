class TownsController < ApplicationController
  before_action :set_town, only: %i[ show edit update destroy ]

  # GET /towns
  def index
    @towns = Town.all
  end

  # GET /towns/1
  def show
  end

  # GET /towns/new
  def new
    @town = Town.new
  end

  # GET /towns/1/edit
  def edit
  end

  # POST /towns
  def create
    @town = Town.new(town_params)

    if @town.save
      redirect_to @town, notice: "Town was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /towns/1
  def update
    if @town.update(town_params)
      redirect_to @town, notice: "Town was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /towns/1
  def destroy
    @town.destroy
    redirect_to towns_url, notice: "Town was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_town
      @town = Town.find(params[:id])
      authorize @town
    end

    # Only allow a list of trusted parameters through.
    def town_params
      params.require(:town).permit(:name, :description_ca, :description_es, :description_fr, :description_en, photos: [])
    end
end
