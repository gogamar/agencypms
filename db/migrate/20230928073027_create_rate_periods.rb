class CreateRatePeriods < ActiveRecord::Migration[7.0]
  def change
    create_table :rate_periods do |t|
      t.string :name
      t.date :firstnight
      t.date :lastnight
      t.integer :min_stay
      t.string :arrival_day

      t.timestamps
    end

    add_reference :rate_periods, :rate_plan, foreign_key: true
  end
end
