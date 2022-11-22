class RstemplatesController < ApplicationController
  before_action :set_rstemplate, only: [:show, :edit, :update, :destroy]

  def index
    @rstemplates = policy_scope(Rstemplate)
  end

  def show
    authorize @rstemplate
  end

  def new
    @rstemplate = Rstemplate.new
    authorize @rstemplate
  end

  def edit
    authorize @rstemplate
  end

  def copy
    @source = Rstemplate.find(params[:id])
    @rstemplate = @source.dup
    @rstemplate.title = "#{@rstemplate.title} CÒPIA"
    authorize @rstemplate
    @rstemplate.save!
    redirect_to rstemplates_path, notice: "S'ha creat una còpia de l'model de contracte #{@rstemplate.title}."
    # render :new
  end

  def create
    @rstemplate = Rstemplate.new(rstemplate_params)
    @rstemplate.user_id = current_user.id
    authorize @rstemplate
    if @rstemplate.save
      redirect_to rstemplates_path, notice: 'Has creat un nou model de contracte de contracte de compravenda.'
    else
      render :new
    end
  end

  def update
    authorize @rstemplate
    if params[:commit] == "Desar com model de contracte nou"
      @rstemplate = Rstemplate.new(rstemplate_params)
      @rstemplate.save!
      redirect_to rstemplates_path, notice: 'S\'ha creat un nou model de contracte'
    elsif params[:commit] == "Desar"
      @rstemplate.update(rstemplate_params)
      redirect_to rstemplates_path, notice: 'S\'ha actualitzat el model de contracte'
    else
      render :edit
    end
  end

  def destroy
    authorize @rstemplate
    @rstemplate.destroy
    redirect_to rstemplates_path, notice: 'El model de contracte s\'ha esborrat.'
  end

  private

  def set_rstemplate
    @rstemplate = Rstemplate.find(params[:id])
  end

  def rstemplate_params
    params.require(:rstemplate).permit(:title, :text, :language)
  end
end
