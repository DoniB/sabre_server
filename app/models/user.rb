class User < ApplicationRecord
  before_save { self.email = email.downcase }
  validates :username, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  has_secure_password

  has_many :secure_tokens
  has_many :recipes
  has_many :comments
  has_many :ratings

  scope :admins, -> { where('is_admin = ?', true) }

end
