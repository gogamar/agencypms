class ChangeDateToDatetime < ActiveRecord::Migration[7.0]
  def change
    change_column :rates, :date_sent_to_beds, :datetime
  end
end
