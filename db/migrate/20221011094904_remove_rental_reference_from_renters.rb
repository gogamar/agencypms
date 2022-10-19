class RemoveRentalReferenceFromRenters < ActiveRecord::Migration[7.0]
  def change
    remove_reference :renters, :rental, index: true, foreign_key: true
  end
end
