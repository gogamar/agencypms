class RentaltemplatesController < ApplicationController
  before_action :set_rentaltemplate, only: [:show, :edit, :update, :destroy]

  def index
    @rentaltemplates = policy_scope(Rentaltemplate)
  end

  def show
    authorize @rentaltemplate
  end

  def new
    @rentaltemplate = Rentaltemplate.new
    authorize @rentaltemplate
  end

  def edit
    authorize @rentaltemplate
  end

  def create
    @rentaltemplate = Rentaltemplate.new(rentaltemplate_params)
    @rentaltemplate.user_id = current_user.id
    authorize @rentaltemplate
    if @rentaltemplate.save
      redirect_to rentaltemplates_path, notice: 'Has creat un nou model de contracte de contracte de lloguer.'
    else
      render :new
    end
  end

  def update
    authorize @rentaltemplate
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
    authorize @rentaltemplate
    @rentaltemplate.destroy
    redirect_to rentaltemplates_path, notice: 'El model de contracte s\'ha esborrat.'
    # if @rentaltemplate.agreement
    #   redirect_to rentaltemplates_path, notice: 'El model de contracte no s\'ha pogut esborrar perque es utilitzada per un contracte.'
    # else
    #   redirect_to rentaltemplates_path, notice: 'El model de contracte s\'ha esborrat.'
    # end
  end

  private

  def set_rentaltemplate
    @rentaltemplate = Rentaltemplate.find(params[:id])
  end

  def rentaltemplate_params
    params.require(:rentaltemplate).permit(:title, :text, :content)
  end
end
