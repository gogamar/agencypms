class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @tasks = policy_scope(Task)
  end


  def show
    authorize @task
  end

  def new
    @task = Task.new
    authorize @task
  end

  def edit
    authorize @task
  end

  def create
    @task = Task.new(task_params)
    @task.user_id = current_user.id
    authorize @task
    if @task.save
      redirect_to tasks_path, notice: "Has creat una tasca nova."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @task
    if @task.update(task_params)
      redirect_to tasks_path, notice: 'Has actualitzat la tasca.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task
    @task.destroy
    redirect_to tasks_url, notice: 'Has esborrat la tasca.'
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def task_params
    params.require(:task).permit(:title, :description, :start_time, :end_time)
  end
end
