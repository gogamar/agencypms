class AddWeeklyRateAndNightlyRatesToRates < ActiveRecord::Migration[7.0]
  def change
    add_reference :rates, :weekly_rate, foreign_key: { to_table: :rates }
  end
end
