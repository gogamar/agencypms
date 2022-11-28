class AddFieldsToContracts < ActiveRecord::Migration[7.0]
  def change
    add_column :contracts, :dp_part1, :float
    add_column :contracts, :dp_part2, :float
    add_column :contracts, :dp_part1_text, :string
    add_column :contracts, :dp_part2_text, :string
    add_column :contracts, :signdate_notary, :date
    add_column :contracts, :min_notice, :string
    add_column :contracts, :court, :string
  end
end
