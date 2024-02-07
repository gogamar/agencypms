class PostsController < ApplicationController
  before_action :set_post, only: %i[ edit update destroy toggle_hidden ]
  before_action :set_category, except: %i[ index destroy toggle_hidden get_news ]
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
    redirect_back fallback_location: posts_path, notice: "Post was successfully destroyed."
  end

  def get_news
    FeedImporter.import_feeds

    from = params[:from].to_date.strftime('%Y-%m-%dT00:00:00Z')
    search_params = { from: from, lang: params[:lang], country: params[:country], max: params[:max], param1: params[:param1], param2: params[:param2], param3: params[:param3], param4: params[:param4]}

    if lang != 'ca'
      NewsApiService.get_news_from_gnews(search_params)
    end
    redirect_to posts_path, notice: "News imported successfully."
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
