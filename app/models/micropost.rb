class Micropost < ApplicationRecord
  belongs_to :user

  mount_uploader :picture, PictureUploader

  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size

  scope :order_desc, ->{order created_at: :DESC}

  private

  def picture_size
    return unless picture.size > 5.megabytes
    errors.add :picture, I18n.t("less_than_5MB")
  end
end
