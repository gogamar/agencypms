class CreateJoinTableCouponsVrentals < ActiveRecord::Migration[7.0]

  def change
    create_table :coupons do |t|
      t.string :name
      t.decimal :amount, precision: 10, scale: 2
      t.string :discount_type
      t.integer :usage_limit
      t.date :last_date
    end

    create_join_table :coupons, :vrentals
  end
end
