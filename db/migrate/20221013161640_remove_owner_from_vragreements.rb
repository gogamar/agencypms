class RemoveOwnerFromVragreements < ActiveRecord::Migration[7.0]
  def change
    remove_reference :vragreements, :owner, index: true, foreign_key: true
  end
end
