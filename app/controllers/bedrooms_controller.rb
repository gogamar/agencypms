class BedroomsController < ApplicationController
  before_action :set_bedroom, only: %i[ show edit update destroy ]

  # GET /bedrooms
  def index
    @bedrooms = Bedroom.all
  end

  # GET /bedrooms/1
  def show
  end

  # GET /bedrooms/new
  def new
    @bedroom = Bedroom.new
  end

  # GET /bedrooms/1/edit
  def edit
  end

  # POST /bedrooms
  def create
    @bedroom = Bedroom.new(bedroom_params)

    if @bedroom.save
      redirect_to @bedroom, notice: "Bedroom was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bedrooms/1
  def update
    if @bedroom.update(bedroom_params)
      redirect_to @bedroom, notice: "Bedroom was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /bedrooms/1
  def destroy
    @bedroom.destroy
    redirect_to bedrooms_url, notice: "Bedroom was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bedroom
      @bedroom = Bedroom.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bedroom_params
      params.require(:bedroom).permit(:bedroom_type, :vrental_id, beds_attributes: [:id, :bed_type, :_destroy])
    end
end
