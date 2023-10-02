class BathroomsController < ApplicationController
  before_action :set_bathroom, only: %i[ show edit update destroy ]

  # GET /bathrooms
  def index
    @bathrooms = Bathroom.all
  end

  # GET /bathrooms/1
  def show
  end

  # GET /bathrooms/new
  def new
    @bathroom = Bathroom.new
  end

  # GET /bathrooms/1/edit
  def edit
  end

  # POST /bathrooms
  def create
    @bathroom = Bathroom.new(bathroom_params)

    if @bathroom.save
      redirect_to @bathroom, notice: "Bathroom was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bathrooms/1
  def update
    if @bathroom.update(bathroom_params)
      redirect_to @bathroom, notice: "Bathroom was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /bathrooms/1
  def destroy
    @bathroom.destroy
    redirect_to bathrooms_url, notice: "Bathroom was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bathroom
      @bathroom = Bathroom.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bathroom_params
      params.require(:bathroom).permit(:bathroom_type, :vrental_id)
    end
end
