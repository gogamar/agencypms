class RemoveOwnerFromAgreements < ActiveRecord::Migration[7.0]
  def change
    remove_reference :agreements, :owner, index: true, foreign_key: true
  end
end
