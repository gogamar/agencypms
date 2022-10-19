class FeaturesController < ApplicationController
  before_action :set_feature, only: [ :show, :edit, :update, :destroy ]
  before_action :set_vrental, only: [ :new, :create, :edit ]
  def new
    @feature = Feature.new
    @features = Feature.distinct.pluck(:name).map {|feature| t("#{feature}")}
  end

  def index
    @features = Feature.all
    # @features = @vrental.features
  end

  def show
    # @vrental = Vrental.find_by(id: @feature.vrental_id)
  end


  def edit
  end

  # POST /features
  def create
    @feature = Feature.new(feature_params)
    @feature.vrental = @vrental
    if @feature.save
      redirect_to @vrental, notice: 'Has afegit una nova caracteristica.'
    else
      render :new
    end
  end

  # PATCH/PUT /features/1
  def update
    if @feature.update(feature_params)
      redirect_to @feature, notice: 'Has actualitzat la caracteristica.'
    else
      render :edit
    end
  end

  # DELETE /features/1
  def destroy
    @feature.destroy
    redirect_to vrental_path(@feature.vrental), notice: 'Has esborrat la caracteristica.'
  end

  private

  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
  end

  def set_feature
    @feature = Feature.find(params[:id])
  end

  def feature_params
    params.require(:feature).permit(:name, :vrental_id)
  end
end
