class AddSentToBedsToRates < ActiveRecord::Migration[7.0]
  def change
    add_column :rates, :sent_to_beds, :boolean
  end
end
