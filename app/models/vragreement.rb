class Vragreement < ApplicationRecord
  belongs_to :vrentaltemplate
  belongs_to :vrental
  validates :status, presence: true
  validates :year, uniqueness: { scope: :vrental_id }
  validates :vrentaltemplate_id, presence: true
  has_many_attached :photos

  def vrental_description
    case vrentaltemplate.language
    when "ca"
      vrental.description
    when "es"
      vrental.description_es
    when "fr"
      vrental.description_fr
    when "en"
      vrental.description_en
    else
      ""
    end
  end

  def vrental_features
    vrental.features.pluck(:name).map {|str| I18n.t("#{str}")}.sort_by {|t| t }.join(", ").capitalize()
  end

  def generate_details(contract_rates)
    {
      data_firma: signdate.present? ? I18n.l(signdate, format: :long) : '',
      lloc_firma: place.present? ? place : '',
      propietari: vrental.vrowner.present? && vrental.vrowner.fullname.present? ? vrental.vrowner.fullname : '',
      dni_propietari: vrental.vrowner.present? && vrental.vrowner.document.present? ? vrental.vrowner.document : '',
      adr_propietari: vrental.vrowner.present? && vrental.vrowner.address.present? ? vrental.vrowner.address : '',
      email_propietari: vrental.vrowner.present? && vrental.vrowner.email.present? ? vrental.vrowner.email : '',
      tel_propietari: vrental.vrowner.present? && vrental.vrowner.phone.present? ? vrental.vrowner.phone : '',
      compte_propietari: vrental.vrowner.present? && vrental.vrowner.account.present? ? vrental.vrowner.account : '',
      nom_immoble: vrental.name.present? ? vrental.name.upcase() : '',
      adr_immoble: vrental.address.present? ? vrental.address : '',
      cadastre: vrental.cadastre.present? ? vrental.cadastre : '',
      cedula: vrental.habitability.present? ? vrental.habitability : '',
      num_HUT: vrental.licence.present? ? vrental.licence : '',
      descripcio: vrental_description.to_s,
      data_inici: start_date.present? ? I18n.l(start_date, format: :long) : '',
      data_fi: end_date.present? ? I18n.l(end_date, format: :long) : '',
      tarifes: contract_rates.present? ? contract_rates : '',
      reserves_propietari: vrowner_bookings,
      carac_immoble: vrental_features.to_s,
      comissio: format("%.2f", vrental.commission.to_f * 100),
      clausula_adicional: clause.to_s
    }
  end

  def generate_contract_body(contract_rates)
    body = vrentaltemplate.text.to_s
    Vragreement.parse_template(body, generate_details(contract_rates))
  end

  def self.parse_template(template, attrs = {})
    result = template
    attrs.each { |field, value| result.gsub!("{{ #{field} }}", value) }
    # remove anything that resembles a field but did not match a known field name
    result.gsub!(/\{\{\.w+\}\}/, '')
    return result
  end
end
