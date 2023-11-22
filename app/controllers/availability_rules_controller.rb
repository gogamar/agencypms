class AvailabilityRulesController < ApplicationController
  before_action :set_vrental, only: [ :new, :create, :edit, :update ]
  before_action :set_availability_rule, only: [:edit, :update, :destroy]

  def index
    @vrental = Vrental.find(params[:vrental_id])
    @availability_rules = policy_scope(@vrental.availability_rules)
    @available_dates = @availability_rules.where('inventory > ?', 0)
  end

  def new
    @availability_rule = AvailabilityRule.new
    authorize @availability_rule
  end

  def edit
  end

  def create
    @availability_rule = AvailabilityRule.new(availability_rule_params)
    authorize @availability_rule
    @availability_rule.vrental = @vrental

    if @availability_rule.save
      redirect_to vrental_availability_rules_path, notice: "La regla de disponibilitat s'ha creat correctament."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @availability_rule.update(availability_rule_params)
      redirect_to vrental_availability_rules_path(@vrental), notice: "La regla de disponibilitat s'ha modificat correctament."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @availability_rule
    @availability_rule.destroy
    redirect_to vrental_availability_rules_path(@vrental), notice: "S'ha esborrat la regla de disponibilitat."
  end

  private

  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
    authorize @vrental
  end

  def set_availability_rule
    @availability_rule = AvailabilityRule.find(params[:id])
    authorize @availability_rule
  end

  def availability_rule_params
    params.require(:availability_rule).permit(:on_date, :inventory, :multiplier, :override, :vrental_id)
  end
end
