class AddCleaningCompanyToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_reference :vrentals, :cleaning_company, foreign_key: true
  end
end
