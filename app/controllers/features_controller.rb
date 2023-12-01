class FeaturesController < ApplicationController
  before_action :set_feature, only: [ :show, :edit, :update, :destroy ]

  # Index for features is not really necessary
  def index
    @features = policy_scope(Feature).order('highlight DESC')
  end

  def new
    @feature = Feature.new
    authorize @feature
    @features = Feature.all
  end

  def show
  end

  def edit
  end

  def create
    @feature = Feature.new(feature_params)
    @feature.company = @company
    authorize @feature
    if @feature.save
      redirect_to features_path, notice: 'Has afegit una nova caracteristica.'
    else
      render :new
    end
  end

  def update
    if @feature.update(feature_params)
      redirect_to features_path, notice: 'Has actualitzat la caracteristica.'
    else
      render :edit
    end
  end

  def destroy
    @feature.destroy
    redirect_to vrental_path(@feature.vrental), notice: 'Has esborrat la caracteristica.'
  end

  private

  def set_feature
    @feature = Feature.find(params[:id])
    authorize @feature
  end

  def feature_params
    params.require(:feature).permit(:name, :highlight, :vrental_id, :company_id)
  end
end
