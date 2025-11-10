class BlogPost < ApplicationRecord
  has_rich_text :body
  has_one_attached :mrta_image
  has_one_attached :banner_image
end
