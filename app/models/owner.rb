class Owner < ApplicationRecord
  belongs_to :user, optional: true
  has_many :vrentals, dependent: :nullify
  has_many :vragreements, through: :vrentals
  validates :fullname, presence: true
  validates :language, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ }

  def grant_access(company)
    temporary_password = Devise.friendly_token.first(8)
    owner_user = User.new(email: email, password: temporary_password, password_confirmation: temporary_password, approved: true, company_id: company.id)

    owner_user.skip_confirmation_notification!

    if owner_user.save
      self.user = owner_user
      save
      owner_user.created_by_admin = true
      owner_user.send_reset_password_instructions_with_locale(self.language)
      owner_user.send_confirmation_instructions_with_locale(self.language)
    else
      errors.add(:base, "No s'ha pogut crear l'usuari. Pot ser ja existeix.")
    end
  end
end
