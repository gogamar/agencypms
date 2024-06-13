class CreateCleaningSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :cleaning_schedules do |t|
      t.integer :priority
      t.date :cleaning_date
      t.datetime :cleaning_start
      t.datetime :cleaning_end
      t.date :next_booking_date
      t.string :next_booking_info
      t.boolean :locked, default: false
      t.references :booking, foreign_key: true
      t.references :cleaning_company, foreign_key: true

      t.timestamps
    end
  end
end
