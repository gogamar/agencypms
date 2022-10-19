require 'date'
require 'time'
require 'beds24'
require 'csv'


auth_token = 'Jsnns2022Estartit'
client = Beds24::JSONClient.new auth_token
beds24rentals = client.get_properties


# 1

# puts "Destroying all existing vacation rental owners"
# Vrowner.destroy_all
# puts "Importing vacation rental owners from a csv file.."

# filepath = "db/vrowners.csv"

# CSV.foreach(filepath, headers: true, col_sep: ";") do |row|
#   Vrowner.create!(
#     fullname: row["Owner"],
#     document: row["Document"],
#     address: row["Address"],
#     email: row["Email"],
#     phone: row["Phone"],
#     account: row["Account"],
#     beds_room_id: row["Room"],
#     language: row["Language"]
#   )
# end

# puts "Created #{Vrowner.count} vacation rental owners."

# 2

# puts "Destroying all existing vacation rentals..."
# Vrental.destroy_all
# puts "Existing rates and vacation rentals deleted."

# puts "Importing vacation rentals from Beds24"
# beds24rentals.each do |bedsrental|
#   #unless bedsrental["propId"] == rental.beds_prop_id
#   Vrental.create!(
#       name: bedsrental["name"],
#       address: bedsrental["address"] + ', ' + bedsrental["postcode"] + ' ' + bedsrental["city"],
#       beds_prop_id: bedsrental["propId"],
#       beds_room_id: bedsrental["roomTypes"][0]["roomId"],
#       max_guests: bedsrental["roomTypes"][0]["maxPeople"].to_i
#       )
#       sleep 1
#   #end
# end
# puts "Imported #{Vrental.count} vacation rentals from Beds24"

# 3

# puts "Assigning each owner to its vacation rental in rails..."

# @vrentals = Vrental.all

# @vrentals.each do |vrental|
#   if vrental.vrowner_id
#     puts "The #{vrental.name} already has an owner assigned."
#   else
#     vrowner = Vrowner.find_by(beds_room_id: vrental.beds_room_id)
#     if vrowner
#       vrental.vrowner_id = vrowner.id
#       vrental.save!
#       puts "Assigned owner to #{vrental.name}"
#     else
#       puts "The #{vrental.name} doesn't have a corresponding owner."
#     end
#   end
# end

# puts "Done assigning owners!"

# 4

# puts "Importing cadastre, habitability and commission from vrowners csv file"

# @vrentals = Vrental.all

# filepath = "db/vrowners.csv"

# CSV.foreach(filepath, headers: true, col_sep: ";") do |row|
#   @vrentals.each do |vrental|
#     if vrental.beds_room_id == row["Room"]
#       vrental.cadastre = row["Cadastre"]
#       vrental.habitability = row["Habitability"]
#       vrental.commission = row["Commission"]
#       vrental.save!
#     end
#   end
# end

# puts "Done adding fields from vrowners csv file."

# 5

# puts "Importing licence from licences csv file"

# @vrentals = Vrental.all

# filepath = "db/licences.csv"

# CSV.foreach(filepath, headers: true, col_sep: ";") do |row|
#   @vrentals.each do |vrental|
#     if vrental.beds_prop_id == row["Property"]
#       vrental.licence = row["Licence"]
#       vrental.save!
#     end
#   end
# end

# puts "Done adding fields from licences csv file."

# 6

# puts "Adding secret API prop keys from beds"

# @vrentals = Vrental.all

# @vrentals.each do |vrental|
#   # unless vrental.prop_key
#   vrental.prop_key = vrental.name.delete(" ").downcase + "2022987123654"
#   vrental.save!
#   # end
# end

# puts "Done adding secret API keys!"

# 7

# puts "Adding rates to the vrentals without rates..."

# @vrentalsnorates = Vrental.where.missing(:rates).where(status: 'active')

# @vrentalsnorates.each do |vrental|
#   prop_key = vrental.prop_key
#   beds24rates = client.get_rates(prop_key)
#     # if beds24rates.blank?
#     #   puts "There are no rates for #{vrental.name}."
#     # else
#       beds24rates.each do |rate|
#         if rate["firstNight"].delete("-").to_i > 20220101 && rate["pricesPer"] == "7"
#           Rate.create!(
#             firstnight: rate["firstNight"],
#             lastnight: rate["lastNight"],
#             priceweek: rate["roomPrice"],
#             beds_room_id: rate["roomId"],
#             vrental_id: vrental.id
#           )
#           puts "Imported rates for #{vrental.name}."
#         else
#           puts "There is no weekly rate for #{vrental.name}."
#         end
#     sleep 1
#       end
#     # end
# end

# 8 Done already

# @vrowners = Vrowner.all

# puts "Assigning each owner to its rental in rails..."

# @vrentals.each do |vrental|
#   if vrental.vrowner_id
#     puts "The #{vrental.name} already has a vacation rental owner assigned."
#   else
#     vrowner = Vrowner.find_by(beds_room_id: vrental.beds_room_id)
#     if vrowner
#       vrental.vrowner_id = vrowner.id
#       vrental.save!
#       puts "Assigned vacation rental owner to #{vrental.name}"
#     else
#       puts "The #{vrental.name} doesn't have a corresponding owner on the csv list."
#     end
#   end
# end

#  9

# puts "Copying rates from 2022 to 2023"

# @rates = Rate.all
# @rates.each do |existingrate|
#   Rate.create!(
#     firstnight: existingrate.firstnight + 364,
#     lastnight: existingrate.lastnight + 364,
#     pricenight: existingrate.pricenight,
#     priceweek: existingrate.priceweek,
#     beds_room_id: existingrate.beds_room_id,
#     vrental_id: existingrate.vrental_id
#   )
# end

# 10

# Add minimum stay and arrival day to all rates

# @rates = Rate.all
# puts 'Adding default min stay and arrival date to all!'
# @rates.each do |rate|
#   rate.min_stay = 5
#   rate.arrival_day = "everyday"
#   rate.save!
# end
# puts "Added default min stay (5) and arrival day (always)!"

# puts 'Adding min stay (7) and arrival date (Saturday) for summers!'

# @rates.each do |rate|
#   if rate.firstnight >= Date.parse('2022-07-09') && rate.lastnight <= Date.parse('2022-08-26')
#     rate.min_stay = 7
#     rate.arrival_day = "saturdays"
#     rate.save!
#   elsif rate.firstnight >= Date.parse('2023-07-08') && rate.lastnight <= Date.parse('2023-08-25')
#     rate.min_stay = 7
#     rate.arrival_day = "saturdays"
#     rate.save!
#   end
# end

# puts 'Added min stay (7) and arrival date (Saturday) for summers!'

# 11
# puts "Importing all the descriptions..."

# @vrentals = Vrental.where(description: nil)
# @vrentals.each do |vrental|
#   prop_key = vrental.prop_key
#   beds24descriptions = client.get_property_content(prop_key, roomIds: true, texts: true)
#   if beds24descriptions["roomIds"]
#     beds24descriptions["roomIds"].each do |room|
#       vrental.description = room[1]["texts"]["contentDescriptionText"]["CA"]
#       vrental.description_es = room[1]["texts"]["contentDescriptionText"]["ES"]
#       vrental.description_fr = room[1]["texts"]["contentDescriptionText"]["FR"]
#       vrental.description_en = room[1]["texts"]["contentDescriptionText"]["EN"]
#       vrental.save!
#       puts "Imported the descriptions for #{vrental.name}!"
#     end
#   end
# end

# puts "Done!"

# 12
# puts "Destroying all features..."
# Feature.destroy_all
# puts "Importing features and linking them to the vacation rentals..."

# @vrentals = Vrental.all
# @vrentals.each do |vrental|
  # prop_key = vrental.prop_key
  # beds24descriptions = client.get_property_content(prop_key, roomIds: true, texts: true)
  # if beds24descriptions["roomIds"]
  #   beds24descriptions["roomIds"].each do |room|
  #     room[1]["featureCodes"].each do |feature|
  #       Feature.create!(
  #         name: feature[0].downcase,
  #         beds_room_id: room[1]["roomId"],
  #         vrental_id: vrental.id
  #       )
  #     end
  #     puts "Imported the features for #{vrental.name}!"
  #     sleep 1
  #   end
  # end
# end

# puts "Done!"

# 13
# puts "Changing the names of arrival day"
# @rates = Rate.all
# @rates.each do |rate|
#   if rate.arrival_day == "t '.everyday'"
#     rate.arrival_day = "everyday"
#   elsif rate.arrival_day == "t '.saturdays'"
#     rate.arrival_day = "saturdays"
#   end
#   rate.save!
# end
# puts "Done!"

# 14
# puts "Removing unnecessary features..."
# @features = Feature.all
# @features.each do |feature|
#   if feature.name == "beach" || feature.name == "linens" || feature.name == "towels" || feature.name == "hangers" || feature.name == "toiletries" || feature.name == "dishes_utensils" || feature.name == "stove" || feature.name == "kitchen" || feature.name == "swimming" || feature.name == "scuba_or_snorkeling" || feature.name == "kayaking" || feature.name == "sailing" || feature.name =="cycling" || feature.name == "bedroom" || feature.name == "bathroom" || feature.name == "bedroom_living_sleeping_combo" || feature.name == "bathroom_full" || feature.name == "town" || feature.name == "downtown" || feature.name == "water_hot" || feature.name == "sitting_area" || feature.name == "village" || feature.name == "bathroom_half" || feature.name == "living_room" || feature.name == "resort" || feature.name == "golf" || feature.name == "bicycle" || feature.name == "children_welcome"
#     feature.destroy
#   end
# end
# puts "Done!"

# 15

# puts "Destroying all the existing agreements"

# Vragreement.destroy_all


# @vrentals = Vrental.all
#   @vrentals.each do |vrental|
#   if vrental.vrowner.present?
#     if vrental.vrowner.language == "ca"
#       Vragreement.create!(
#         signdate: Date.parse("2022/12/01"),
#         place: "Estartit",
#         start_date: Date.parse("2023/04/01"),
#         end_date: Date.parse("2023/09/30"),
#         vrentaltemplate_id: Vrentaltemplate.find_by(language: "ca").id,
#         vrental_id: vrental.id,
#         vrowner_bookings: "El propietari encara no ha bloquejat cap data per al seu propi ús. Si vol bloquejar algunes dates, si us plau contacti amb nosaltres a info@sistachrentals.com.",
#         clause: "La propietat autoritza a rebaixar el preu de lloguers pactats que els turistes paguen en un 10% en el cas que faltant 4 setmanes per a la data no hi hagués cap reserva confirmada.
#         La propietat autoritza a augmentar un 15% els preus de venda al públic establerts, de forma excepcional per a les reserves que entrin del portal www.booking.com, quedant la totalitat d'aquest increment en benefici de l'agència per poder pagar el 15% de comissions que el referit portal cobra a l'agència."
#       )
#       puts "Added agreements in Catalan."
#     elsif vrental.vrowner.language == "es"
#       Vragreement.create!(
#         signdate: Date.parse("2022/12/01"),
#         place: "Estartit",
#         start_date: Date.parse("2023/04/01"),
#         end_date: Date.parse("2023/09/30"),
#         vrentaltemplate_id: Vrentaltemplate.find_by(language: "es").id,
#         vrental_id: vrental.id,
#         vrowner_bookings: "El propietario todavía no ha bloqueado ninguna fecha para su propio uso. Si desea bloquear algunas fechas, por favor contacte con nosotros enviando un email a info@sistachrentals.com.",
#         clause: "La propiedad autoriza a rebajar el precio de alquileres pactados que los turistas pagan en un 10% en el caso de que faltando 4 semanas para la fecha no hubiera ninguna reserva confirmada.
#         La propiedad autoriza a aumentar un 15% los precios de venta al público establecidos, de forma excepcional para las reservas que entren del portal www.booking.com, quedando la totalidad de este incremento en beneficio de la agencia para poder pagar el 15% de comisiones que el referido portal cobra a la agencia."
#       )
#       puts "Added agreements in Spanish."
#     elsif vrental.vrowner.language == "fr"
#       Vragreement.create!(
#         signdate: Date.parse("2022/12/01"),
#         place: "Estartit",
#         start_date: Date.parse("2023/04/01"),
#         end_date: Date.parse("2023/09/30"),
#         vrentaltemplate_id: Vrentaltemplate.find_by(language: "fr").id,
#         vrental_id: vrental.id,
#         vrowner_bookings: "Le propriétaire n'a pas encore verrouillé de dates pour son propre usage. Si vous souhaitez bloquer certaines dates, veuillez nous contacter à info@sistachrentals.com.",
#         clause: "Réduction de dernière minute 10%: Le propriétaire autorise à réduire les tarifs de location convenus de 10% dans le cas où 4 semaines avant il n'y a pas de réservation confirmée.
#         Le Propriétaire autorise l'augmentation des tarifs de location établis de 15%, exceptionnellement pour les réservations effectuées via le site www.booking.com, afin que l'Agence puisse couvrir la commission de 15% que le portail référencé facture à l'Agence."
#       )
#       puts "Added agreements in French."
#     elsif vrental.vrowner.language == "en"
#       Vragreement.create!(
#         signdate: Date.parse("2022/12/01"),
#         place: "Estartit",
#         start_date: Date.parse("2023/04/01"),
#         end_date: Date.parse("2023/09/30"),
#         vrentaltemplate_id: Vrentaltemplate.find_by(language: "en").id,
#         vrental_id: vrental.id,
#         vrowner_bookings: "The owner has not yet blocked any dates for their personal use. If the owner would like to block some dates for their own use, please contact us at info@sistachrentals.com.",
#         clause: "Last minute reduction 10%: The Property Owner authorizes to reduce the agreed rental rates by 10% in the event that 4 weeks before there are no confirmed reservations.
#         The Property Owner authorizes the increase of the established rental rates by 15%, exceptionally for reservations made through the website www.booking.com, so that the Agency can cover the 15% commission that the referred portal charges to the Agency."
#       )
#       puts "Added agreements in English."
#     end
#   end
# end
