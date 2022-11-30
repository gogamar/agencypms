class AddStatusToVragreements < ActiveRecord::Migration[7.0]
  def change
    add_column :vragreements, :status, :string
  end
end
