class CreateRatePlans < ActiveRecord::Migration[7.0]
  def change
    create_table :rate_plans do |t|
      t.string :name
      t.date :start
      t.date :end
      t.integer :gen_min
      t.string :gen_arrival

      t.timestamps
    end

    add_reference :rate_plans, :company, foreign_key: true
    add_reference :vrentals, :rate_plan, foreign_key: true
  end
end
