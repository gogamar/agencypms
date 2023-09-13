class AddVrownerToVrownerPayment < ActiveRecord::Migration[7.0]
  def change
    add_reference :vrowner_payments, :vrowner, null: false, foreign_key: true
  end
end
