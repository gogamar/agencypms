class CreateCleaningSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :cleaning_plans do |t|
      t.date :from
      t.date :to
      t.references :cleaning_company, null: false, foreign_key: true

      t.timestamps
    end

    create_table :cleaning_schedules do |t|
      t.datetime :cleaning_start
      t.datetime :cleaning_end
      t.references :cleaning_plan, foreign_key: true
      t.references :vrental, null: false, foreign_key: true

      t.timestamps
    end
  end
end
