class AddOfficeToCoupons < ActiveRecord::Migration[7.0]
  def change
    add_reference :coupons, :office, null: false, foreign_key: true
  end
end
