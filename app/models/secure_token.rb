class SecureToken < ApplicationRecord
  TOKEN_LENGTH = 140
  before_validation :initialize_attributes

  validates :token, presence: true, uniqueness: true, length: { minimum: TOKEN_LENGTH }
  validates :expires, :user_id, presence: true

  belongs_to :user

  def SecureToken.generate_token
    SecureRandom.urlsafe_base64 TOKEN_LENGTH
  end

private
  def initialize_attributes
    self.token = SecureToken.generate_token if token.nil?
    self.expires = 30.days.from_now if expires.nil?
    self.created_at = Time.now if created_at.nil?
  end

end
