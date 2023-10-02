class ImageUrlsController < ApplicationController
  before_action :set_image_url, only: %i[ show edit update destroy ]

  # GET /image_urls
  def index
    @image_urls = ImageUrl.all
  end

  # GET /image_urls/1
  def show
  end

  # GET /image_urls/new
  def new
    @image_url = ImageUrl.new
  end

  # GET /image_urls/1/edit
  def edit
  end

  # POST /image_urls
  def create
    @image_url = ImageUrl.new(image_url_params)

    if @image_url.save
      redirect_to @image_url, notice: "Image url was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /image_urls/1
  def update
    if @image_url.update(image_url_params)
      redirect_to @image_url, notice: "Image url was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /image_urls/1
  def destroy
    @image_url.destroy
    redirect_to image_urls_url, notice: "Image url was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image_url
      @image_url = ImageUrl.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def image_url_params
      params.require(:image_url).permit(:url, :order)
    end
end
