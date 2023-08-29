class VrownersController < ApplicationController
  before_action :set_vrowner, only: [:show, :edit, :update, :destroy]

  def index
    all_vrowners = policy_scope(Vrowner).order(:fullname)
    @pagy, @vrowners = pagy(all_vrowners, page: params[:page], items: 10)
  end

  def filter
    @vrowners = policy_scope(Vrowner)
    @languages = Vrowner.pluck("language").uniq
    @vrowners = @vrowners.where('fullname ilike ?', "%#{params[:fullname]}%") if params[:fullname].present?
    @vrowners = @vrowners.where(language: params[:language]) if params[:language].present?
    @pagy, @vrowners = pagy(@vrowners, page: params[:page], items: 9)
    render(partial: 'vrowners', locals: { vrowners: @vrowners })
  end

  def show
    authorize @vrowner

    respond_to do |format|
      format.html do
        render :show
      end
      format.json do
        render json: {
          fullname: vrowner.fullname,
          modal_content: render_to_string(partial: "edit_vrowner_modal", locals: { vrowner: vrowner })
        }
      end
    end
  end

  def new
    @vrental = Vrental.find(params[:vrental_id])
    @vrowner = Vrowner.new
    authorize @vrental
    authorize @vrowner
  end

  def create
    @vrental = Vrental.find(params[:vrental_id]) if params[:vrental_id].present?

    @vrowner = Vrowner.new(vrowner_params)
    @vrowner.user = current_user
    @vrental.vrowner = @vrowner if @vrental.present?
    authorize @vrowner

    request_context = params[:vrowner][:request_context]

    if @vrowner.save && @vrental.update_columns(vrowner_id: @vrowner.id)
      if request_context && request_context == 'add_vrowner'
        redirect_to vrentals_path, notice: 'Nou immoble i propietari creats.'
      else
        redirect_to edit_vrental_path(@vrental), notice: 'Propietari creat i associat amb immoble.'
      end
    else
      render @vrental.persisted? ? :new : :add_vrowner
    end
  end

  def edit
    authorize @vrowner
  end

  def update
    @vrental = Vrental.find(params[:vrental_id]) if params[:vrental_id].present?
    authorize @vrowner
    if @vrowner.update(vrowner_params)
      if params[:vrental_id].present?
        redirect_back(fallback_location: edit_vrental_path(@vrental), notice: 'Has modificat el propietari.')
      else
        redirect_to vrowners_path, notice: 'Has modificat el propietari.'
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @vrowner

    vrentals = @vrowner.vrentals
    vrentals.update_all(vrowner_id: nil) # Dissociate vrentals from vrowner

    if @vrowner.destroy
      redirect_to vrowners_path, notice: "S'ha esborrat el propietari."
    else
      redirect_back(fallback_location: vrowners_path, alert: "No s'ha pogut esborrar el propietari.")
    end
  end

  private

  def set_vrowner
    @vrowner = Vrowner.find(params[:id])
  end

  def vrowner_params
    params.require(:vrowner).permit(:fullname, :address, :phone, :email, :document, :account, :language, :beds_room_id, :beds_prop_id, :user_id)
  end
end
