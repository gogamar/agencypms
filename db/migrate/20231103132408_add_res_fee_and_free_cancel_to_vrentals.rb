class AddResFeeAndFreeCancelToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :res_fee, :decimal, precision: 10, scale: 2
    add_column :vrentals, :free_cancel, :integer
  end
end
