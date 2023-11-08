class CouponsController < ApplicationController
  before_action :set_office, only: [:new, :create, :index, :edit, :update, :apply_to_all]
  before_action :set_coupon, only: [:edit, :update, :destroy, :apply_to_all]

  def new
    @coupon = Coupon.new
    authorize @coupon
  end

  def index
    @coupons = policy_scope(Coupon).order('last_date DESC')
  end

  def apply_to_all
    @vrentals = @office.vrentals
    @vrentals.each do |vrental|
      vrental.coupons << @coupon
    end
    redirect_to company_office_coupons_path(@company, @office), notice: "Has aplicat el codi #{@coupon.name} a tots els immobles de la oficina #{@office.name}."
  end

  def create
    @coupon = Coupon.new(coupon_params)
    @coupon.office = @office
    authorize @coupon
    if @coupon.save
      redirect_to company_office_coupons_path(@company, @office), notice: "Has creat un nou codi de descompte per la oficina #{@office.name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @coupon.update(coupon_params)
      flash.now[:notice] = "Has actualitzat el codi de descompte #{@coupon.name}."
      redirect_to company_office_coupons_path(@company, @office)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @coupon.destroy
    redirect_to company_office_coupons_path(@company, @office), notice: "Has esborrat el codi de descompte."
  end

  private

  def set_office
    @office = Office.find(params[:office_id])
  end

  def set_coupon
    @coupon = Coupon.find(params[:id])
    authorize @coupon
  end

  def coupon_params
    params.require(:coupon).permit(:name, :amount, :discount_type, :usage_limit, :last_date, :office_id)
  end
end
