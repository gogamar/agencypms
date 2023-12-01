class VrentaltemplatesController < ApplicationController
  before_action :set_vrentaltemplate, only: [:show, :edit, :update, :destroy]

  def index
    @vrentaltemplates = policy_scope(Vrentaltemplate)
  end

  def show
  end

  def new
    @vrentaltemplate = Vrentaltemplate.new
    authorize @vrentaltemplate
  end

  def edit
  end

  def copy
    @source = Vrentaltemplate.find(params[:id])
    @vrentaltemplate = @source.dup
    @vrentaltemplate.title = "#{@vrentaltemplate.title} CÒPIA"
    authorize @vrentaltemplate
    @vrentaltemplate.save!
    redirect_to vrentaltemplates_path, notice: "S'ha creat una còpia de l'model de contracte #{@vrentaltemplate.title}."
  end

  def create
    @vrentaltemplate = Vrentaltemplate.new(vrentaltemplate_params)
    @vrentaltemplate.company_id = @company.id
    authorize @vrentaltemplate
    if @vrentaltemplate.save
      redirect_to edit_vrentaltemplate_path(@vrentaltemplate), notice: 'Has creat un nou model de contracte de lloguer turístic.'
    else
      render :new
    end
  end

  def update
    if params[:commit] == "Desar com model de contracte nou"
      @vrentaltemplate = Vrentaltemplate.new(vrentaltemplate_params)
      @vrentaltemplate.save!
      redirect_to vrentaltemplates_path, notice: 'S\'ha creat un nou model de contracte'
    elsif params[:commit] == "Desar"
      @vrentaltemplate.update(vrentaltemplate_params)
      redirect_to vrentaltemplates_path, notice: 'S\'ha actualitzat el model de contracte'
    else
      render :edit
    end
  end

  def destroy
    @vrentaltemplate.destroy
    redirect_to vrentaltemplates_path, notice: 'El model de contracte s\'ha esborrat.'
  end

  private

  def set_vrentaltemplate
    @vrentaltemplate = Vrentaltemplate.find(params[:id])
    authorize @vrentaltemplate
  end

  def vrentaltemplate_params
    params.require(:vrentaltemplate).permit(:title, :text, :language, :public, :company_id)
  end
end
