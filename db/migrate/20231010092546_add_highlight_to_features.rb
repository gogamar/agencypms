class AddHighlightToFeatures < ActiveRecord::Migration[7.0]
  def change
    add_column :features, :highlight, :boolean, default: false
  end
end
