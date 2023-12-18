class RemoveSentToBedsFromRates < ActiveRecord::Migration[7.0]
  def change
    remove_column :rates, :sent_to_beds, :boolean
    remove_column :rates, :date_sent_to_beds, :datetime
  end
end
