class RentersController < ApplicationController
  before_action :set_renter, only: [:show, :edit, :update, :destroy]

  def index
    all_renters = policy_scope(Renter)
    @pagy, @renters = pagy(all_renters, page: params[:page], items: 10)
  end

  def filter
    @renters = policy_scope(Renter)
    @languages = Renter.pluck("language").uniq
    @renters = @renters.where('fullname ilike ?', "%#{params[:fullname]}%") if params[:fullname].present?
    @renters = @renters.where(language: params[:language]) if params[:language].present?
    @pagy, @renters = pagy(@renters, page: params[:page], items: 10)
    render(partial: 'renters', locals: { renters: @renters })
  end

  def show
    authorize @renter
  end

  def new
    @renter = Renter.new
    authorize @renter
  end

  def create
    @renter = Renter.new(renter_params)
    @renter.user_id = current_user.id
    authorize @renter
    if @renter.save
      redirect_to renters_path, notice: "Has creat un nou inquili de lloguer anual."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @renter
  end

  def update
    authorize @renter
    if @renter.update(renter_params)
      redirect_to renters_path, notice: "Has actualitzat a l'inquili"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @renter
    @renter.destroy
    redirect_to renters_path, notice: "Has esborrat a l'inquili #{@renter.fullname}."
  end

  private

  def set_renter
    @renter = Renter.find(params[:id])
  end

  def renter_params
    params.require(:renter).permit(:fullname, :address, :phone, :email, :document, :account, :language)
  end
end
