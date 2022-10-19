class RentersController < ApplicationController
    # before_action :set_owner, only: [:show]
    before_action :set_renter, only: [:show, :edit, :update]

    # GET /renters
    def index
      @renters = Renter.all
      # @renters = renter.where(owner_id: @owner)
    end

    # GET /renters/1
    def show
    end

    # GET /renters/new
    def new
      @renter = Renter.new
    end

    # GET /renters/1/edit
    def edit
    end

    # POST /renters
    def create
      @renter = Renter.new(renter_params)
      if @renter.save
        redirect_back fallback_location: renters_path, notice: "Has creat un inquili nou."
      else
        render 'new'
      end
    end

    # PATCH/PUT /renters/1
    def update
      if @renter.update(renter_params)
        redirect_to @renter, notice: 'renter was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /renters/1
    def destroy
      @renter.destroy
      redirect_to renters_url, notice: 'renter was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_renter
        @renter = Renter.find(params[:id])
      end
    # Only allow a list of trusted parameters through.
    def renter_params
      params.require(:renter).permit(:fullname, :address, :document, :account, :language)
    end
end
