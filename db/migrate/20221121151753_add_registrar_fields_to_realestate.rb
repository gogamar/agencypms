class AddRegistrarFieldsToRealestate < ActiveRecord::Migration[7.0]
  def change
    add_column :realestates, :registrar, :string
    add_column :realestates, :volume, :string
    add_column :realestates, :book, :string
    add_column :realestates, :sheet, :string
    add_column :realestates, :registry, :string
    add_column :realestates, :entry, :string
    add_column :realestates, :charges, :text
    add_column :realestates, :habitability, :string
    add_column :realestates, :hab_date, :date
  end
end
