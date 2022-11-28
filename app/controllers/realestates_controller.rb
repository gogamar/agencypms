class RealestatesController < ApplicationController
  before_action :set_realestate, only: [:show, :edit, :update, :destroy]

  def index
    all_realestates = policy_scope(Realestate)
    @pagy, @realestates = pagy(all_realestates, page: params[:page], items: 10)
    # .sort_by(&:created_at).reverse
  end

  def list
    @realestates = policy_scope(Realestate).includes(:seller)
    @realestates = @realestates.where('address ilike ?', "%#{params[:address]}%") if params[:address].present?
    @realestates = @realestates.where(status: params[:status]) if params[:status].present?
    @realestates = @realestates.order("#{params[:column]} #{params[:direction]}")
    @pagy, @realestates = pagy(@realestates, page: params[:page], items: 10)
    render(partial: 'realestates', locals: { realestates: @realestates })
  end

  def show
    authorize @realestate
    @seller = @realestate.seller
  end

  def new
    @realestate = Realestate.new
    authorize @realestate
  end

  def copy
    @source = Realestate.find(params[:id])
    @realestate = @source.dup
    @realestate.address = "#{@realestate.address} CÒPIA"
    authorize @realestate
    @realestate.save!
    redirect_to realestates_path, notice: "S'ha creat una còpia de l'immoble: #{@realestate.address}."
  end

  def edit
    authorize @realestate
  end

  def create
    @realestate = Realestate.new(realestate_params)
    @realestate.user_id = current_user.id
    authorize @realestate
    if @realestate.save
      redirect_to realestates_path, notice: 'Has creat un nou immoble.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @realestate
    if @realestate.update(realestate_params)
      redirect_to realestates_path, notice: 'Has actualitzat l\'immoble.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @realestate
    @realestate.destroy
    redirect_to realestates_url, notice: 'S\'ha esborrat l\'immoble.'
  end

  private

  def set_realestate
    @realestate = Realestate.find(params[:id])
  end

  def realestate_params
    params.require(:realestate).permit(:address, :cadastre, :energy, :seller_id, :description, :city, :status, :registrar, :volume, :book, :sheet, :registry, :entry, :charges, :habitability, :hab_date, :description_screenshot, :charges_screenshot, :registry_code)
  end
end
