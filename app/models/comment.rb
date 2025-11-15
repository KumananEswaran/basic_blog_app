class Comment < ApplicationRecord
  belongs_to :blog_post
  belongs_to :user, optional: true

  validates :body, presence: true
  validates :name, presence: true, unless: -> { user.present? } 
end
