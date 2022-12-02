class BuyersController < ApplicationController
  before_action :set_buyer, only: [:show, :edit, :update, :destroy]

  def index
    all_buyers = policy_scope(Buyer)
    @pagy, @buyers = pagy(all_buyers, page: params[:page], items: 10)
  end

  def filter
    @buyers = policy_scope(Buyer)
    @languages = Buyer.pluck("language").uniq
    @buyers = @buyers.where('fullname ilike ?', "%#{params[:fullname]}%") if params[:fullname].present?
    @buyers = @buyers.where(language: params[:language]) if params[:language].present?
    @pagy, @buyers = pagy(@buyers, page: params[:page], items: 10)
    render(partial: 'buyers', locals: { buyers: @buyers })
  end

  def show
    authorize @buyer
  end

  def new
    @buyer = Buyer.new
    authorize @buyer
  end

  def create
    @buyer = Buyer.new(buyer_params)
    @buyer.user_id = current_user.id
    authorize @buyer
    if @buyer.save
      redirect_to buyers_path, notice: "Has creat un nou comprador."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @buyer
  end

  def update
    authorize @buyer
    if @buyer.update(buyer_params)
      redirect_to buyers_path, notice: "Has actualitzat al comprador"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @buyer
    @buyer.destroy
    redirect_to buyers_path, notice: "Has esborrat al comprador #{@buyer.fullname}."
  end

  private

  def set_buyer
    @buyer = Buyer.find(params[:id])
  end

  def buyer_params
    params.require(:buyer).permit(:fullname, :address, :phone, :email, :document, :account, :account_bank, :language)
  end
end
