class AddRentalTermAndMinStayToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :rental_term, :string
    add_column :vrentals, :min_stay, :integer
  end
end
