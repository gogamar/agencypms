class AddSignatoryToVragreements < ActiveRecord::Migration[7.0]
  def change
    add_column :vragreements, :signatory, :integer
  end
end
