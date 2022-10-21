class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home
    # hotwire guy
    before_action :find_ownersandrentals
    # hotwire guy


  def home
    @owners = Owner.all
    @rentals = @owner&.rentals || []

    @selected_vrowners = Vrowner.includes(:vrentals).where('user_id = ?', '2').references(:vrentals)

    # @selected_vrowners = Vrowner.includes(:vrentals).where(vrentals: { user_id: current_user.id })
  end



  private

  def find_ownersandrentals
    @owner = Owner.find_by(id: params[:owner].presence)
    @rental = Rental.find_by(id: params[:rental].presence)
  end

end
