class ContactForm < ApplicationRecord
  validates :name, :email, :subject, :message, presence: true
end
