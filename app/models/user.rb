class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :blog_posts, dependent: :nullify
  has_many :comments, dependent: :nullify

  validates :username, presence: true, uniqueness: true
end
