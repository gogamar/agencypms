class AddNightsToRatesAndRatePeriods < ActiveRecord::Migration[7.0]
  def change
    add_column :rates, :nights, :integer
    add_column :rate_periods, :nights, :integer
  end
end
