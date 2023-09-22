class AddLanguageToCompany < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :language, :string
  end
end
