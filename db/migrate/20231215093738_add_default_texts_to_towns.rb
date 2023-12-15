class AddDefaultTextsToTowns < ActiveRecord::Migration[7.0]
  def change
    add_column :towns, :access_text_en, :text
    add_column :towns, :access_text_ca, :text
    add_column :towns, :access_text_es, :text
    add_column :towns, :access_text_fr, :text
    add_column :towns, :house_rules_en, :text
    add_column :towns, :house_rules_ca, :text
    add_column :towns, :house_rules_es, :text
    add_column :towns, :house_rules_fr, :text
  end
end
