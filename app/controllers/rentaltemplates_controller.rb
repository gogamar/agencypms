class RentaltemplatesController < ApplicationController
  before_action :set_rentaltemplate, only: [:show, :edit, :update, :destroy]
  # before_action :set_owner, only: [:show]
  # GET /rentaltemplates
  def index
    @rentaltemplates = Rentaltemplate.all
  end

  # GET /rentaltemplates/1
  def show
  end

  # GET /rentaltemplates/new
  def new
    @rentaltemplate = Rentaltemplate.new
  end

  # GET /rentaltemplates/1/edit
  def edit
  end

  # POST /rentaltemplates
  def create
    @rentaltemplate = Rentaltemplate.new(rentaltemplate_params)

    if @rentaltemplate.save
      redirect_to rentaltemplates_path, notice: 'Has creat un nou model de contracte de contracte de lloguer.'
    else
      render :new
    end
  end

  # PATCH/PUT /rentaltemplates/1
  def update
    if params[:commit] == "Desar com model de contracte nou"
      @rentaltemplate = Rentaltemplate.new(rentaltemplate_params)
      @rentaltemplate.save!
      redirect_to @rentaltemplate, notice: 'S\'ha creat un nou model de contracte'
    elsif params[:commit] == "Desar"
      @rentaltemplate.update(rentaltemplate_params)
      redirect_to @rentaltemplate, notice: 'S\'ha actualitzat el model de contracte'
    else
      render :edit
    end
  end

  # DELETE /rentaltemplates/1
  def destroy
    @rentaltemplate.destroy
    redirect_to rentaltemplates_path, notice: 'El model de contracte s\'ha esborrat.'
    # if @rentaltemplate.agreement
    #   redirect_to rentaltemplates_path, notice: 'El model de contracte no s\'ha pogut esborrar perque es utilitzada per un contracte.'
    # else
    #   redirect_to rentaltemplates_path, notice: 'El model de contracte s\'ha esborrat.'
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rentaltemplate
      @rentaltemplate = Rentaltemplate.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def rentaltemplate_params
      params.require(:rentaltemplate).permit(:title, :text, :content)
    end
end
