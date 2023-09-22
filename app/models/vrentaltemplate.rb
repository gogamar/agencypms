class Vrentaltemplate < ApplicationRecord
  has_many :vragreements
  belongs_to :user
  validates :title, presence: true
  validates :language, presence: true

  TEMPLATE_KEYS = [
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
  ].freeze
end
