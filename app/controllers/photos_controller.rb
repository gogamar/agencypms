class PhotosController < ApplicationController
  before_action :skip_authorization

  def destroy
    photo = ActiveStorage::Attachment.find(params[:id])
    photo.purge
    redirect_back fallback_location: root_path, notice: "Has esborrat #{photo.filename}."
  end
end
