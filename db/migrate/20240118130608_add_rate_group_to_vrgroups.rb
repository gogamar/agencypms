class AddRateGroupToVrgroups < ActiveRecord::Migration[7.0]
  def change
    add_column :vrgroups, :rate_group, :boolean, default: false
  end
end
