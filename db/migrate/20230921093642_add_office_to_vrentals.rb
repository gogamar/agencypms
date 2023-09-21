class AddOfficeToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_reference :vrentals, :office, foreign_key: true
  end
end
