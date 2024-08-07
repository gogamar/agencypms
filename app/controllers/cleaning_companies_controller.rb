class CleaningCompaniesController < ApplicationController
  before_action :set_cleaning_company, only: [:show, :edit, :update, :destroy]

  def index
    @cleaning_companies = policy_scope(CleaningCompany)
  end

  def show
  end

  def new
    @cleaning_company = CleaningCompany.new
    authorize @cleaning_company
    @offices = Office.all
  end

  def create
    @cleaning_company = CleaningCompany.new(cleaning_company_params)
    authorize @cleaning_company
    if @cleaning_company.save
      render(partial: 'cleaning_company', locals: { cleaning_company: @cleaning_company})
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @cleaning_company.update(cleaning_company_params)
      flash.now[:notice] = "Has actualitzat l'empresa de neteja #{@cleaning_company.name}."
      redirect_to cleaning_companies_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cleaning_company.destroy
    redirect_to cleaning_companies_path, notice: "Has esborrat l'empresa de neteja."
  end

  private

  def set_cleaning_company
    @cleaning_company = CleaningCompany.find(params[:id])
    authorize @cleaning_company
  end

  def cleaning_company_params
    params.require(:cleaning_company).permit(:name, :number_of_cleaners, :cost_per_hour, :office_id)
  end
end
