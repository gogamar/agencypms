class AddCompanyToStatementsInvoicesVragreements < ActiveRecord::Migration[7.0]
  def change
    add_reference :statements, :company, foreign_key: true
    add_reference :invoices, :company, foreign_key: true
    add_reference :vragreements, :company, foreign_key: true
  end
end
