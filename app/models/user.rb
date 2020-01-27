class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :first_name, presence: true, length: { in: 2..30 }
  validates :last_name, presence: true, length: { in: 2..30 }
  validates :birthday, presence: true
  validates :gender, presence: true

  # Associations
  has_many :posts, foreign_key: 'creator_id', dependent: :destroy
  has_many :likes, foreign_key: 'liker_id', dependent: :destroy
  has_many :comments, foreign_key: 'commenter_id', dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy

  # Methods
  def friends
    friends_array = friendships.map { |friendship| friendship.friend if friendship.confirmed }
    result = friends_array + inverse_friendships.map { |friendship| friendship.user if friendship.confirmed }
    result.compact
  end

  def pending_friends
    friendships.map { |friendship| friendship.friend if !friendship.confirmed }.compact
  end

  def friends_requests
    inverse_friendships.map { |friendship| friendship.user if !friendship.confirmed }.compact
  end

  def confirm_friend(user)
    friendship = inverse_friendships.find { | friendship | friendship.user == user }
    friendship.confirmed = true
    friendship.save
  end

  def friend?(user)
    friends.include?(user)
  end

  def pending_friend?(user)
    pending_friends.include?(user)
  end  

  def is_requested?(user)
    friends_requests.include?(user)
  end
end
