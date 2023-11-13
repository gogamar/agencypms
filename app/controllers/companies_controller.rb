class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show edit update destroy ]

  def index
    @companies = policy_scope(Company)
  end

  def show
  end

  def new
    @company = Company.new
    authorize @company
  end

  def edit
  end

  def create
    @company = Company.new(company_params)
    @company = current_user.build_owned_company(company_params)
    current_user.company = @company
    authorize @company

    if @company.save
      redirect_to new_company_office_path(@company), notice: "Empresa creada. Ara pots afegir oficines."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @company.update(company_params)
      redirect_to edit_company_path, notice: "Empresa actualitzada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    redirect_to root_path, notice: "Empresa esborrada."
  end

  private
    def set_company
      @company = Company.find(params[:id])
      authorize @company
    end

    def company_params
      params.require(:company).permit(:name, :language, :street, :city, :vat_number, :user_id, :post_code, :region, :country, :bank_account, :administrator, :vat_tax, :vat_tax_payer, :realtor_number, :logo)
    end
end
