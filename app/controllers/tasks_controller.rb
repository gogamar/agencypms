class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @tasks = policy_scope(Task).order(start_date: :asc).order(start_time: :asc)
    # @tasks = Task.where("start_date >= ?", Date.today)
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@tasks.count} cites", # filename: "Posts: #{@posts.count}"
               template: "tasks/index",
               formats: [:html],
               disposition: :inline,
               page_size: 'A4',
               dpi: '75',
               zoom: 1,
               layout: 'plain',
               margin:  {   top:    20,
                            bottom: 20,
                            left:   10,
                            right:  10}
      end
    end
  end

  def show
    authorize @task
  end

  def new
    @task = Task.new
    authorize @task
    @tasks = policy_scope(Task)
    @default_date = Date.parse(params[:starts_at])
  end

  def edit
    authorize @task
    @tasks = policy_scope(Task)
  end

  def create
    @task = Task.new(task_params)
    @task.user_id = current_user.id
    authorize @task
    if @task.save
      redirect_to root_path, notice: "Has creat una tasca nova."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @task
    if @task.update(task_params)
      redirect_to root_path, notice: 'Has actualitzat la tasca.'
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    authorize @task
    @task.destroy
    redirect_to root_path, notice: 'Has esborrat la tasca.'
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def task_params
    params.require(:task).permit(:title, :start_date, :start_time)
  end
end
