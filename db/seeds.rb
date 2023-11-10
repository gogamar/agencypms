ocean_view = Feature.find_by(name: "ocean_view")
if ocean_view.present?
  ocean_view.update(name: "sea_view")
end

Vrental.where(min_price: nil).each do |vrental|
  if vrental.rates && vrental.rates.minimum(:priceweek)
    min_price = vrental.rates.minimum(:priceweek) / 7
  elsif vrental.rates && vrental.rates.minimum(:pricenight)
    min_price = vrental.rates.minimum(:pricenight)
  else
    min_price = 50
  end
  vrental.min_price = min_price
  vrental.save!
  puts "#{vrental.name} min_price: #{min_price}"
end

Vrental.all.each do |vrental|
  vrental.features.clear
  vrental.get_content_from_beds
end

estartit_office = Office.find_by("name ILIKE '%estartit%'")

estartit_office.vrentals.each do |vrental|
  vrental.name_on_web = true
  vrental.save!
end

barcelona_office = Office.find_by("name ILIKE '%barcelona%'")

barcelona_vrentals = barcelona_office.vrentals

barcelona_vrentals.where("name ILIKE ? AND name NOT ILIKE ?", "%exterior%", "%mensual%").each do |vrental|
  vrental.title_ca = "Vista Sagrada Familia"
  vrental.title_es = "Vista Sagrada Familia"
  vrental.title_fr = "Vue Sagrada Familia"
  vrental.title_en = "View Sagrada Familia"
  vrental.save!
end

barcelona_vrentals.where("name ILIKE ? AND name NOT ILIKE ?", "%interior%", "%mensual%").each do |vrental|
  vrental.title_ca = "Sagrada Familia Apartament"
  vrental.title_es = "Sagrada Familia Apartamento"
  vrental.title_fr = "Sagrada Familia Appartement"
  vrental.title_en = "Sagrada Familia Apartment"
  vrental.save!
end

# # medium term rentals

barcelona_vrentals.where("name ILIKE ? AND name ILIKE ?", "%exterior%", "%mensual%").each do |vrental|
  vrental.title_ca = "Vista Sagrada Familia: mensual"
  vrental.title_es = "Vista Sagrada Familia: mensual"
  vrental.title_fr = "Vue Sagrada Familia: mensuelle"
  vrental.title_en = "View Sagrada Familia: monthly"
  vrental.save!
end

barcelona_vrentals.where("name ILIKE ? AND name ILIKE ?", "%interior%", "%mensual%").each do |vrental|
  vrental.title_ca = "Apt. Sagrada Familia: mensual"
  vrental.title_es = "Apt. Sagrada Familia: mensual"
  vrental.title_fr = "Appt. Sagrada Familia: mensuelle"
  vrental.title_en = "Apt. Sagrada Familia: monthly"
  vrental.save!
end

puts "Done!"
