class AddGapDaysToVrgroups < ActiveRecord::Migration[7.0]
  def change
    add_column :vrgroups, :gap_days, :integer
  end
end
