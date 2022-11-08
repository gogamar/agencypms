class Vrowner < ApplicationRecord
  belongs_to :user
  has_many :vrentals
  has_many :vragreements, through: :vrentals
  validates :fullname, presence: {
    message: ->(object, data) do
      "Es obligatori posar nom."
    end}
  validates :language, presence: { message: "Es obligatori triar l'idioma del propietari."}
end
