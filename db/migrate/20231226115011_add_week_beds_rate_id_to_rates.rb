class AddWeekBedsRateIdToRates < ActiveRecord::Migration[7.0]
  def change
    add_column :rates, :week_beds_rate_id, :string
  end
end
