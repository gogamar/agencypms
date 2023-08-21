class BlocksController < ApplicationController
  # skip_before_action :authenticate_user!, only: :home
  before_action :set_block, only: [:show, :edit, :update, :destroy]

  def new
    @block = Block.new
    authorize @block
  end

  def show
    authorize @block
  end

  def edit
    authorize @block
  end

  def create
    @block = Block.new(rate_params)
    @block.page = Page.find(params[:page_id])
    authorize @block
    if @block.save
      redirect_to block_path(@block), notice: "Has creat una secció nova."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @block
    if @block.update(block_params)
      flash.now[:notice] = "Has actualitzat la secció."
      redirect_to @block
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    authorize @block
    @block.destroy
    redirect_to root, notice: "Has esborrat la secció correctament."
  end

  private

  def set_block
    @block = Block.find(params[:id])
  end

  def block_params
    params.require(:block).permit(:title_en, :title_ca, :title_es, :title_fr, :subtitle_en, :subtitle_ca, :subtitle_es, :subtitle_fr, :content_en, :content_ca, :content_es, :content_fr, :button_en, :button_ca, :button_es, :button_fr, :page_id)
  end
end
