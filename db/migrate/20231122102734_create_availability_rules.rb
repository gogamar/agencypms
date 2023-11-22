class CreateAvailabilityRules < ActiveRecord::Migration[7.0]
  def change
    create_table :availability_rules do |t|
      t.date :on_date
      t.integer :inventory
      t.integer :multiplier
      t.integer :override
      t.references :vrental, null: false, foreign_key: true

      t.timestamps
    end
  end
end
