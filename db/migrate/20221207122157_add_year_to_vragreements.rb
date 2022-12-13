class AddYearToVragreements < ActiveRecord::Migration[7.0]
  def change
    add_column :vragreements, :year, :integer
  end
end
