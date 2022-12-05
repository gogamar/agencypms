class FeaturesController < ApplicationController
  before_action :set_feature, only: [ :show, :edit, :update, :destroy ]

  # Index for features is not really necessary
  def index
    @features = policy_scope(Feature)
  end

  def new
    @feature = Feature.new
    authorize @feature
    @features = Feature.all
  end

  def show
    authorize @feature
  end

  def edit
    authorize @feature
  end

  def create
    @feature = Feature.new(feature_params)
    authorize @feature
    if @feature.save
      redirect_to features_path, notice: 'Has afegit una nova caracteristica.'
    else
      render :new
    end
  end

  def update
    authorize @feature
    if @feature.update(feature_params)
      redirect_to features_path, notice: 'Has actualitzat la caracteristica.'
    else
      render :edit
    end
  end

  def destroy
    authorize @feature
    @feature.destroy
    redirect_to vrental_path(@feature.vrental), notice: 'Has esborrat la caracteristica.'
  end

  private

  def set_feature
    @feature = Feature.find(params[:id])
  end

  def feature_params
    params.require(:feature).permit(:name, :vrental_id)
  end
end
