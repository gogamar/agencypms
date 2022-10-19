class RemoveVrownerFromVragreements < ActiveRecord::Migration[7.0]
  def change
    remove_reference :vragreements, :vrowner, index: true, foreign_key: true
  end
end
