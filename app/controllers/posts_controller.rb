class PostsController < ApplicationController
  include NewsHelper
  before_action :set_post, only: %i[ edit update destroy toggle_hidden ]
  before_action :skip_authorization, only: %i[ get_news ]

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
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
    end
  end

  def edit
  end

  def create
    @post = Post.new(post_params)
    authorize @post
    @post.user = current_user
    @post.published_at = params[:post][:published_at].to_datetime || Time.now

    if @post.save
      redirect_to posts_path, notice: "Post was successfully created."
    else
      puts "this is the post errors: #{@post.errors}"
      render :new, status: :unprocessable_entity
    end
  end

  def toggle_hidden
    @post.update(hidden: params[:hidden])

    redirect_back fallback_location: posts_path, notice: "Post visibility updated."
  end

  def update
    if @post.update(post_params)
      redirect_to posts_path, notice: "Post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_back fallback_location: posts_path, notice: "Post was successfully destroyed."
  end

  def get_news
    if params[:context] == 'rss_feed'
      FeedImporter.import_feeds
    else
      from = params[:from].to_date.strftime('%Y-%m-%dT00:00:00Z') if params[:from].present?
      search_query = build_search_query(params)
      search_params = { from: from, lang: params[:lang], country: params[:country], max: params[:max] }

      NewsApiService.get_news_from_gnews(search_query, search_params)
    end
    redirect_to posts_path, notice: "News imported successfully."
  end

  private

  def set_post
    @post = Post.find(params[:id])
    authorize @post
  end

  def post_params
    params.require(:post).permit(:title_ca, :title_es, :title_en, :title_fr, :content_ca, :content_es, :content_en, :content_fr, :category_id, :user_id, :image, :feed_id, :published_at, :url, :hidden, :guid, :source)
  end
end
