class OwnersController < ApplicationController
  before_action :set_owner, only: [:show, :edit, :update, :destroy, :grant_access]

  def index
    all_owners = policy_scope(Owner).order(created_at: :desc)
    @pagy, @owners = pagy(all_owners, page: params[:page], items: 10)
  end

  def filter
    @owners = policy_scope(Owner)
    @languages = Owner.pluck("language").uniq
    @owners = @owners.left_joins(:vrentals)
    .where('owners.fullname ilike ? OR vrentals.name ilike ?', "%#{params[:property_or_owner_name]}%", "%#{params[:property_or_owner_name]}%")
    .distinct if params[:property_or_owner_name].present?
    @owners = @owners.where(language: params[:language]) if params[:language].present?
    @pagy, @owners = pagy(@owners, page: params[:page], items: 9)
    render(partial: 'owners', locals: { owners: @owners })
  end

  def show
    respond_to do |format|
      format.html do
        render :show
      end
      format.json do
        render json: {
          fullname: owner.fullname,
          modal_content: render_to_string(partial: "edit_owner_modal", locals: { owner: owner })
        }
      end
    end
  end

  def new
    @vrental = Vrental.find(params[:vrental_id]) if params[:vrental_id]
    authorize @vrental if @vrental
    @owner = Owner.new
    authorize @owner
  end

  def create
    @vrental = Vrental.find(params[:vrental_id]) if params[:vrental_id].present?
    @owner = Owner.new(owner_params)
    @owner.user = current_user
    @vrental.owner = @owner if @vrental.present?
    authorize @owner

    request_context = params[:owner][:request_context]

    if @owner.save
      @vrental.update_columns(owner_id: @owner.id) if @vrental.present?
      if request_context && request_context == 'add_owner'
        redirect_to vrentals_path, notice: 'Nou immoble i propietari creats.'
      elsif @vrental.present?
        redirect_to add_owner_vrental_path(@vrental), notice: 'Propietari creat i associat amb immoble.'
      else
        redirect_to owners_path, notice: 'Propietari creat.'
      end
    else
      render @vrental.persisted? ? :new : :add_owner
    end
  end

  def edit
  end

  def update
    @vrental = Vrental.find(params[:vrental_id]) if params[:vrental_id].present?
    if @owner.update(owner_params)
      if params[:vrental_id].present?
        redirect_back(fallback_location: edit_vrental_path(@vrental), notice: 'Has modificat el propietari.')
      else
        redirect_to owners_path, notice: 'Has modificat el propietari.'
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    vrentals = @owner.vrentals
    vrentals.update_all(owner_id: nil) # Dissociate vrentals from owner

    if @owner.destroy
      redirect_to owners_path, notice: "S'ha esborrat el propietari."
    else
      redirect_back(fallback_location: owners_path, alert: "No s'ha pogut esborrar el propietari.")
    end
  end

  def grant_access
    @owner.grant_access(@company)
    redirect_to owners_path, notice: "S'ha concedit l'accés al propietari."
  end

  private

  def set_owner
    @owner = Owner.find(params[:id])
    authorize @owner
  end

  def owner_params
    params.require(:owner).permit(:fullname, :address, :phone, :email, :document, :account, :language, :beds_room_id, :beds_prop_id, :user_id)
  end
end
