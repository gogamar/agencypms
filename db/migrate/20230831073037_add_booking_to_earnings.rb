class AddBookingToEarnings < ActiveRecord::Migration[7.0]
  def change
    add_reference :earnings, :booking, foreign_key: true
  end
end
