class PostsController < ApplicationController
  before_action :set_post, only: %i[ edit update destroy toggle_hidden ]
  before_action :set_category, except: %i[ index destroy toggle_hidden ]

  def index
    @posts = policy_scope(Post)
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @posts = @category.posts
    end
    @attribute_names = [:title_ca, :title_en, :title_es, :title_fr]
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

  def toggle_hidden
    @post.update(hidden: params[:hidden])

    redirect_back fallback_location: posts_path, notice: "Post visibility updated."
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
    params.require(:post).permit(:title_ca, :title_es, :title_en, :title_fr, :content_ca, :content_es, :content_en, :content_fr, :category_id, :user_id, :image, :feed_id, :published_at, :url, :hidden, :guid, :source)
  end
end
