class AddSignOnlineToVragreements < ActiveRecord::Migration[7.0]
  def change
    add_column :vragreements, :sign_online, :boolean, default: true
  end
end
