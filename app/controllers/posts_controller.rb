class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :set_category

  def index
    @posts = policy_scope(Post)
  end

  def show
  end

  def new
    @post = Post.new
    authorize @post
  end

  def edit
  end

  def create
    @post = Post.new(post_params)
    authorize @post
    @post.user = current_user

    if @post.save
      redirect_to category_post_path(@category, @post), notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to category_post_path(@category, @post), notice: "Post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_url, notice: "Post was successfully destroyed."
  end

  private

  def set_post
    @post = Post.find(params[:id])
    authorize @post
  end

  def set_category
    @category = Category.find(params[:category_id])
  end

  def post_params
    params.require(:post).permit(:title_ca, :title_es, :title_en, :title_fr, :content_ca, :content_es, :content_en, :content_fr, :category_id, :user_id, :image, :feed_id, :published_at, :url)
  end
end
