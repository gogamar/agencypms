class AddDateSentToBedsToRates < ActiveRecord::Migration[7.0]
  def change
    add_column :rates, :date_sent_to_beds, :date
  end
end
