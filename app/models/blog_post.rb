class BlogPost < ApplicationRecord
  has_rich_text :body
  has_one_attached :mrta_image
  has_one_attached :banner_image
  belongs_to :user, optional: true
  has_many :comments, dependent: :destroy
end
