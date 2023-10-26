class VrgroupsController < ApplicationController
  before_action :set_vrgroup, only: %i[ show edit update destroy ]

  def index
    @vrgroups = policy_scope(Vrgroup)
  end

  def show
  end

  def new
    @vrgroup = Vrgroup.new
    authorize @vrgroup
  end

  def edit
  end

  def create
    @vrgroup = Vrgroup.new(vrgroup_params)
    authorize @vrgroup

    if @vrgroup.save
      redirect_to @vrgroup, notice: "Vrgroup was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @vrgroup.update(vrgroup_params)
      redirect_to @vrgroup, notice: "Vrgroup was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vrgroup.destroy
    redirect_to vrgroups_url, notice: "Vrgroup was successfully destroyed."
  end

  private
    def set_vrgroup
      @vrgroup = Vrgroup.find(params[:id])
      authorize @vrgroup
    end

    def vrgroup_params
      params.require(:vrgroup).permit(:name, :office_id, photos: [])
    end
end
