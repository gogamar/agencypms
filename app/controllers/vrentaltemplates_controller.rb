class VrentaltemplatesController < ApplicationController
  before_action :set_vrentaltemplate, only: [:show, :edit, :update, :destroy]
  # before_action :set_owner, only: [:show]
  # GET /vrentaltemplates
  def index
    @vrentaltemplates = Vrentaltemplate.all
  end

  # GET /vrentaltemplates/1
  def show
  end

  # GET /vrentaltemplates/new
  def new
    @vrentaltemplate = Vrentaltemplate.new
  end

  # GET /vrentaltemplates/1/edit
  def edit
  end

  def copy
    @source = Vrentaltemplate.find(params[:id])
    @vrentaltemplate = @source.dup
    @vrentaltemplate.title = "#{@vrentaltemplate.title} COPIA"
    @vrentaltemplate.save!
    redirect_to vrentaltemplates_path, notice: "S'ha creat una còpia de l'model de contracte #{@vrentaltemplate.title}."
    # render :new
  end

  # POST /vrentaltemplates
  def create
    @vrentaltemplate = Vrentaltemplate.new(vrentaltemplate_params)

    if @vrentaltemplate.save
      redirect_to vrentaltemplates_path, notice: 'Has creat un nou model de contracte de contracte de lloguer.'
    else
      render :new
    end
  end

  # PATCH/PUT /vrentaltemplates/1
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

  # DELETE /vrentaltemplates/1
  def destroy
    @vrentaltemplate.destroy
    redirect_to vrentaltemplates_path, notice: 'El model de contracte s\'ha esborrat.'
    # if @vrentaltemplate.agreement
    #   redirect_to vrentaltemplates_path, notice: 'El model de contracte no s\'ha pogut esborrar perque es utilitzada per un contracte.'
    # else
    #   redirect_to vrentaltemplates_path, notice: 'El model de contracte s\'ha esborrat.'
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vrentaltemplate
      @vrentaltemplate = Vrentaltemplate.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def vrentaltemplate_params
      params.require(:vrentaltemplate).permit(:title, :text, :language)
    end
end
