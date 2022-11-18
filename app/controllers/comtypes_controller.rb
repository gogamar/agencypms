class ComtypesController < ApplicationController
  before_action :set_comtype, only: [:edit, :update, :destroy]

  def index
    @comtypes = policy_scope(Comtype)
  end

  def new
    @comtype = Comtype.new
    authorize @comtype
  end

  def create
    @comtype = Comtype.new(comtype_params)
    @comtype.user_id = current_user.id
    authorize @comtype
    if @comtype.save
      redirect_to comtypes_path, notice: "Has creat un nou tipus d'empresa."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @comtype
  end

  def update
    authorize @comtype
    if @comtype.update(comtype_params)
      redirect_to comtypes_path, notice: "Has actualitzat el tipus d'empresa"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @comtype
    @comtype.destroy
    redirect_to comtypes_path, notice: "Has esborrat el #{@comtype.company_type}."
  end

  private

  def set_comtype
    @comtype = Comtype.find(params[:id])
  end

  def comtype_params
    params.require(:comtype).permit(:company_type)
  end
end
