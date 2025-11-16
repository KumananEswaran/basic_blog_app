class BlogPost < ApplicationRecord
  has_rich_text :body
  has_one_attached :mrta_image

  validates :title, presence: true
  validate  :body_present
  validate  :banner_attached_on_create

  has_one_attached :banner_image
  belongs_to :user, optional: true
  has_many :comments, dependent: :destroy

  private

  def body_present
    # ActionText stores content in an associated rich text object.
    # Check for blank rich text safely:
    if body.blank? || body.body.to_s.strip == ""
      errors.add(:body, "can't be blank")
    end
  end

  def banner_attached_on_create
    # Only require banner image when creating a new post.
    if new_record? && !banner_image.attached?
      errors.add(:banner_image, "must be attached")
    end
  end
end
