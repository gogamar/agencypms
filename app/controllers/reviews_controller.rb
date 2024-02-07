class ReviewsController < ApplicationController
  before_action :set_vrental
  before_action :set_review, only: %i[update destroy]

  def create
    @review = Review.new(review_params)
    authorize @review

    if @review.save
      redirect_to @vrental, notice: "El comentari s'ha creat correctament."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @review
    if @review.update(review_params)
      redirect_to @vrental, notice: "El comentari s'ha modificat correctament."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @review
    @review.destroy
    redirect_to @vrental, notice: "Review was successfully destroyed."
  end

  private
    def set_review
      @review = Review.find(params[:id])
      authorize @review
    end

    def set_vrental
      @vrental = Vrental.friendly.find(params[:vrental_id])
    end

    def review_params
      params.require(:review).permit(:review_id, :client_name, :client_photo_url, :client_location, :review_time, :rating, :comment, :vrental_id)
    end
end
