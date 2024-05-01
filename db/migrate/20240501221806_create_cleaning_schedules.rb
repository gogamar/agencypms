class CreateCleaningSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :cleaning_schedules do |t|
      t.date :date
      t.datetime :cleaning_start
      t.datetime :cleaning_end
      t.references :cleaning_company, foreign_key: true
      t.references :vrental, null: false, foreign_key: true

      t.timestamps
    end
  end
end
