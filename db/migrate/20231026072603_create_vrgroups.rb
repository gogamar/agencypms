class CreateVrgroups < ActiveRecord::Migration[7.0]
  def change
    create_table :vrgroups do |t|
      t.string :name
      t.references :office, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :vrentals, :vrgroup, foreign_key: true
  end
end
