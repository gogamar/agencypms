class AddClauseToVragreements < ActiveRecord::Migration[7.0]
  def change
    add_column :vragreements, :clause, :text
  end
end
