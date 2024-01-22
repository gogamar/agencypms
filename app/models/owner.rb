class Owner < ApplicationRecord
  belongs_to :user, optional: true
  has_many :vrentals, dependent: :nullify
  has_many :vragreements, through: :vrentals
  validates :fullname, presence: true
  validates :language, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ }

  TITLE = ["mr", "mrs", "ms"]

  def fullname
    owner_title = self.title if self.title.present?
    translated_title = I18n.t(owner_title) if owner_title

    if self.company_name.present?
      self.company_name
    elsif self.firstname.present? && self.lastname.present?
      "#{translated_title} #{self.firstname} #{self.lastname}"
    elsif self.lastname.present?
      "#{translated_title} #{self.lastname}"
    elsif self.firstname.present?
      self.firstname
    end
  end

  def grant_access(company)
    temporary_password = Devise.friendly_token.first(8)
    owner_user = User.new(email: self.email, password: temporary_password, password_confirmation: temporary_password, confirmed_at: Time.now, approved: true, company_id: company.id, created_by_admin: true, firstname: self.firstname, lastname: self.lastname, title: self.title, company_name: self.company_name)

    if owner_user.save
      self.user = owner_user
      self.save
    else
      errors.add(:base, "No s'ha pogut crear l'usuari. Pot ser ja existeix.")
    end
  end
end
