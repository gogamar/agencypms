class VrentalsController < ApplicationController
  # before_action :set_vrowner, only: [:show, :index]
  before_action :set_vrental, only: [:show, :edit, :update, :destroy]

  # GET /vrentals
  def index
    @vrentals = Vrental.all.sort_by(&:name)
    # @vrentals = Vrental.where(owner_id: @owner)
  end

  # GET /vrentals/1
  def show
    @vrental = Vrental.find(params[:id])
    @rate = Rate.new
    @rates = Rate.where(vrental_id: params[:id]).order(:firstnight)
    @feature = Feature.new
    @features = Feature.where(vrental_id: params[:id])
  end

  # GET /vrentals/new
  def new
    @vrental = Vrental.new
    @vrentals = Vrental.all.sort_by(&:name)
  end

  # GET /products/1/copy
  def copy
    @source = Vrental.find(params[:id])
    @vrental = @source.dup
    @vrental.name = "#{@vrental.name} COPIA"
    @vrental.rates = []
    @source.rates.each { |rate| @vrental.rates << rate.dup }
    @vrental.features = []
    @source.features.each { |feature| @vrental.features << feature.dup }
    @vrental.save!
    redirect_to @vrental, notice: 'S\'ha creat una còpia de l\'immoble.'
    # render :new
  end

  # GET /vrentals/1/edit
  def edit

  end

  # POST /vrentals
  def create
    @vrental = Vrental.new(vrental_params)
    # @owner = Owner.find(params[:owner_id])
    @vrental.profile = current_profile
    if @vrental.save
      redirect_to vrental_path(@vrental)
    else
      render 'new'
    end
  end

  # PATCH/PUT /vrentals/1
  def update
    if @vrental.update(vrental_params)
      redirect_to vrentals_path, notice: 'S\'ha modificat l\'immoble.'
    else
      render :edit
    end
  end

  # DELETE /vrentals/1
  def destroy
    @vrental.destroy
    redirect_to vrentals_url, notice: 'S\'ha esborrat l\'immoble.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.



    def set_vrental
      @vrental = Vrental.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def vrental_params
      params.require(:vrental).permit(:name, :address, :licence, :cadastre, :habitability, :commission, :beds_prop_id, :beds_room_id, :prop_key, :vrowner_id, :max_guests, :description, :description_es, :description_fr, :description_en, :status)
    end
end
