# frozen_string_literal: true

class SecureToken < ApplicationRecord
  TOKEN_LENGTH = 140
  before_validation :initialize_attributes

  validates :token, presence: true, uniqueness: true, length: { minimum: TOKEN_LENGTH }
  validates :expires, :user_id, presence: true

  belongs_to :user

  scope :active, -> { where("expires > ?", Time.now) }

  def SecureToken.generate_token
    SecureRandom.urlsafe_base64 TOKEN_LENGTH
  end

private
  def initialize_attributes
    self.token ||= SecureToken.generate_token
    self.expires ||= 30.days.from_now
    self.created_at ||= Time.now
  end
end
