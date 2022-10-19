class UsersController < ApplicationController
  skip_before_action :authenticate_user!

  def purge_photo
    current_user.photo.purge
    redirect_back fallback_location: root_path, notice: "Has esborrat la foto."
  end

  def index
    redirect_back fallback_location: root_path, notice: "Has esborrat el teu compte."
  end

end
