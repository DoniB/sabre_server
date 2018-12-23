# frozen_string_literal: true

class Image < ApplicationRecord
  validate :file_format
  validate :file_required

  has_one_attached :file
  belongs_to :user
  belongs_to :recipe, optional: true

  private

    def file_format
      return unless file.attached?
      return if file.blob.content_type.start_with? "image/"
      file.purge_later
      errors.add(:file, "needs to be an image")
    end

    def file_required
      errors.add(:file, "needs a image attached") unless file.attached?
    end
end
