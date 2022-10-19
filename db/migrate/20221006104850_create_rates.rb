class CreateRates < ActiveRecord::Migration[7.0]
  def change
    create_table :rates do |t|
      t.float :pricenight
      t.string :beds_room_id
      t.date :firstnight
      t.date :lastnight
      t.integer :min_stay
      t.string :arrival_day
      t.float :priceweek
      t.references :vrental, foreign_key: true

      t.timestamps
    end
  end
end
