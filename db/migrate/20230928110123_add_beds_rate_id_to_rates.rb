class AddBedsRateIdToRates < ActiveRecord::Migration[7.0]
  def change
    add_column :rates, :beds_rate_id, :string
  end
end
