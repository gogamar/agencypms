class SellersController < ApplicationController
  before_action :set_seller, only: [:show, :edit, :update, :destroy]

  def index
    all_sellers = policy_scope(Seller)
    @pagy, @sellers = pagy(all_sellers, page: params[:page], items: 10)
  end

  def filter
    @sellers = policy_scope(Seller)
    @languages = Seller.pluck("language").uniq
    @sellers = @sellers.where('fullname ilike ?', "%#{params[:fullname]}%") if params[:fullname].present?
    @sellers = @sellers.where(language: params[:language]) if params[:language].present?
    @pagy, @sellers = pagy(@sellers, page: params[:page], items: 10)
    render(partial: 'sellers', locals: { sellers: @sellers })
  end

  def show
    authorize @seller
  end

  def new
    @seller = Seller.new
    authorize @seller
  end

  def create
    @seller = Seller.new(seller_params)
    @seller.user_id = current_user.id
    authorize @seller
    if @seller.save
      redirect_to sellers_path, notice: "Has creat un nou venedor de lloguer anual."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @seller
  end

  def update
    authorize @seller
    if @seller.update(seller_params)
      redirect_to sellers_path, notice: "Has actualitzat al venedor"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @seller
    @seller.destroy
    redirect_to sellers_path, notice: "Has esborrat al venedor #{@seller.fullname}."
  end

  private

  def set_seller
    @seller = Seller.find(params[:id])
  end

  def seller_params
    params.require(:seller).permit(:fullname, :address, :phone, :email, :document, :account, :language)
  end
end
