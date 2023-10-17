class Vrentaltemplate < ApplicationRecord
  has_many :vragreements
  belongs_to :user
  validates :title, presence: true
  validates :language, presence: true

  TEMPLATE_KEYS = [
    :company_name,
    :company_street,
    :company_city,
    :company_post_code,
    :company_region,
    :company_country,
    :company_bank_account,
    :company_administrator,
    :company_vat_tax,
    :company_vat_number,
    :company_realtor_number,
    :office_local_realtor_number,
    :office_name,
    :office_street,
    :office_city,
    :office_post_code,
    :office_region,
    :office_country,
    :office_phone,
    :office_mobile,
    :office_email,
    :office_website,
    :signdate,
    :place,
    :vrowner_fullname,
    :vrowner_document,
    :vrowner_address,
    :vrowner_email,
    :vrowner_phone,
    :vrowner_account,
    :vrental_name,
    :vrental_address,
    :vrental_cadastre,
    :vrental_habitability,
    :vrental_licence,
    :vrental_description,
    :start_date,
    :end_date,
    :contract_rates,
    :vrowner_bookings,
    :vrental_features,
    :vrental_commission,
    :clause
  ]
end
