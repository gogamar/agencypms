class CreateCleaningCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :cleaning_companies do |t|
      t.string :name
      t.integer :number_of_cleaners
      t.decimal :cost_per_hour
      t.references :office, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :vrentals, :cleaning_company, foreign_key: true
    add_column :vrentals, :cleaning_hours, :float
    add_column :bookings, :checkin_time, :datetime
    add_column :bookings, :checkout_time, :datetime
  end
end
