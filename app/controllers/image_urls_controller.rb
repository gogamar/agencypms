class ImageUrlsController < ApplicationController
  before_action :set_image_url, only: %i[ destroy move ]

  def create
    @image_url = ImageUrl.new(image_url_params)
    authorize @image_url

    if @image_url.save
      redirect_to @image_url, notice: "Image url was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @vrental = @image_url.vrental
    if @image_url.photo_id.present?
      photo = ActiveStorage::Attachment.find(@image_url.photo_id)
      photo.purge
    end
    @image_url.destroy
    redirect_to edit_photos_vrental_path(@vrental), notice: "S'ha esborrat la foto."
  end

  def move
    @image_url.insert_at(params[:position].to_i)
    head :ok
  rescue StandardError => e
    Rails.logger.error("An error occurred in the move action: #{e.message}")
    head :internal_server_error
  end

  private

    def set_image_url
      @image_url = ImageUrl.find(params[:id])
      authorize @image_url
    end

    def image_url_params
      params.require(:image_url).permit(:url, :position, :vrental_id)
    end
end
