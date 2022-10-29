class VrentalsController < ApplicationController
  before_action :set_vrental, only: [:show, :edit, :update, :destroy]

  def index
    @vrentals = policy_scope(Vrental)
    @vrentals = Vrental.all.sort_by(&:created_at).reverse
  end

  def show
    authorize @vrental
    @rate = Rate.new
    @rates = policy_scope(Rate)
    @rates = Rate.where(vrental_id: @vrental).order(:firstnight)
    @features = policy_scope(Feature)
    @features = Feature.all
    @years = [Date.today.last_year.year, Date.today.year, Date.today.next_year.year]
  end

  def new
    @vrental = Vrental.new
    authorize @vrental
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
    authorize @vrental
    @vrental.save!
    redirect_to vrentals_path, notice: 'S\'ha creat una còpia de l\'immoble.'
    # render :new
  end

  def edit
    authorize @vrental
  end


  def create
    @vrental = Vrental.new(vrental_params)
    @vrental.user_id = current_user.id
    authorize @vrental
    if @vrental.save
      redirect_to vrentals_path, notice: 'Has creat un nou immoble.'
    else
      render :new, status: :unprocessable_entity
    end
  end


  def update
    authorize @vrental
    if @vrental.update(vrental_params)
      redirect_to vrentals_path, notice: 'S\'ha modificat l\'immoble.'
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    authorize @vrental
    @vrental.destroy
    redirect_to vrentals_url, notice: 'S\'ha esborrat l\'immoble.'
  end

  private

  def set_vrental
    @vrental = Vrental.find(params[:id])
  end

  def vrental_params
    params.require(:vrental).permit(:name, :address, :licence, :cadastre, :habitability, :commission, :beds_prop_id, :beds_room_id, :prop_key, :vrowner_id, :max_guests, :description, :description_es, :description_fr, :description_en, :status, feature_ids:[])
  end
end
