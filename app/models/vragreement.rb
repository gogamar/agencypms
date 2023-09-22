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
    details = {}
    Vrentaltemplate::TEMPLATE_KEYS.each do |key|
      details[key] = case key
                     when :signdate, :start_date, :end_date
                       send(key).present? ? I18n.l(send(key), format: :long) : ''
                     when :place, :clause
                       send(key).to_s
                     when :vrental_name, :vrental_address, :vrental_cadastre, :vrental_habitability, :vrental_licence, :vrental_description
                      vrental.present? && vrental.send(key[8..]).present? ? vrental.send(key[8..]) : ''
                     when :vrowner_fullname, :vrowner_document, :vrowner_address, :vrowner_email, :vrowner_phone, :vrowner_account
                       vrental.vrowner.present? && vrental.vrowner.send(key[8..]).present? ? vrental.vrowner.send(key[8..]) : ''
                     when :contract_rates
                       contract_rates.present? ? contract_rates : ''
                     when :vrowner_bookings
                       vrowner_bookings
                     when :vrental_features
                       vrental_features.to_s
                     when :vrental_commission
                       format("%.2f", vrental.commission.to_f * 100)
                     else
                       '' # default value
                     end
    end
    details
  end

  def generate_contract_body(contract_rates)
    body = vrentaltemplate.text.to_s
    Vragreement.parse_template(body, generate_details(contract_rates))
  end

  def self.parse_template(template, attrs = {})
    result = template
    attrs.each do |field, value|
      translated_field = I18n.t("vragreement_keys.#{field}")
      result.gsub!("#{translated_field}", value.to_s)
    end
    result.gsub(/\b[A-Z]+_[A-Z]+\b/, '')
    return result
  end
end
