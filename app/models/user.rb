# frozen_string_literal: true

class User < ApplicationRecord
  include PgSearch

  before_save { self.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :username, presence: true
  validates :email, presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  has_secure_password

  has_many :secure_tokens
  has_many :recipes
  has_many :comments
  has_many :ratings
  has_many :favorites
  has_many :recipes_favorites,
           class_name: "Recipe",
           through: :favorites,
           source: :recipe

  default_scope -> { order(id: :desc) }

  scope :admins, -> { where("is_admin = ?", true) }
  scope :actives, -> { where("active = ?", true) }
  scope :page, -> (p = 0) { limit(USERS_PER_PAGE).offset(p * USERS_PER_PAGE) }
  scope :total_pages, -> { (count / USERS_PER_PAGE.to_f).ceil }

  pg_search_scope(
    :search,
      against: %i(
      username
      email
    ),
      using: {
          tsearch: {
              dictionary: "portuguese",
              any_word: true,
              prefix: true
          }
      }
  )

  USERS_PER_PAGE = 30

  def self.total_pages
    (User.count / USERS_PER_PAGE.to_f).ceil
  end
end
