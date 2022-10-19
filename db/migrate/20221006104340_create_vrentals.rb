class CreateVrentals < ActiveRecord::Migration[7.0]
  def change
    create_table :vrentals do |t|
      t.string :name
      t.string :address
      t.string :licence
      t.string :cadastre
      t.string :habitability
      t.string :commission
      t.string :beds_room_id
      t.string :beds_prop_id
      t.string :prop_key
      t.references :vrowner, foreign_key: true

      t.timestamps
    end
  end
end
