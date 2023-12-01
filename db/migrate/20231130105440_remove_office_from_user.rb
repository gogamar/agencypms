class RemoveOfficeFromUser < ActiveRecord::Migration[7.0]
  def change
    remove_reference :users, :office
  end
end
