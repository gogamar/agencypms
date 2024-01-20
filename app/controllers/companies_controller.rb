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

  def edit; end

  def create
    @company = Company.new(company_params)
    @company = current_user.owned_companies.build(company_params)
    # find all existing offices and update their company_id to the new company
    Office.all.update(company_id: @company.id)
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
      redirect_to companies_path, notice: "Empresa actualitzada."
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
      params.require(:company).permit(:name, :language, :street, :city, :vat_number, :user_id, :post_code, :region, :country, :bank_account, :administrator, :vat_tax, :vat_tax_payer, :realtor_number, :logo, :signature, :active)
    end
end
