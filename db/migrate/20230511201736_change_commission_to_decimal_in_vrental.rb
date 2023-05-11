class ChangeCommissionToDecimalInVrental < ActiveRecord::Migration[7.0]
  def up
    add_column :vrentals, :commission_temporary, :decimal, precision: 10, scale: 2

    Vrental.find_each do |rental|
      rental.update_column :commission_temporary, rental.commission.to_d
    end

    remove_column :vrentals, :commission

    rename_column :vrentals, :commission_temporary, :commission
  end

  def down
    rename_column :vrentals, :commission, :commission_temporary
    add_column :vrentals, :commission, :string

    Vrental.find_each do |rental|
      rental.update_column :commission, rental.commission_temporary.to_s
    end

    remove_column :vrentals, :commission_temporary
  end
end
