class RemoveVrownerFromVrownerPayments < ActiveRecord::Migration[7.0]
  def change
    remove_reference :vrowner_payments, :vrowner, foreign_key: true
  end
end
