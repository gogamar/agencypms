class CreateBedroomsBedsBathrooms < ActiveRecord::Migration[7.0]
  def change
    create_table :bedrooms do |t|
      t.string :bedroom_type
      t.references :vrental, null: false, foreign_key: true

      t.timestamps
    end
    create_table :beds do |t|
      t.string :bed_type
      t.references :bedroom, foreign_key: true

      t.timestamps
    end
    create_table :bathrooms do |t|
      t.string :bathroom_type
      t.references :vrental, foreign_key: true

      t.timestamps
    end
  end
end
