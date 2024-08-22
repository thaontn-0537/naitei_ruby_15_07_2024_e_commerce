class User < ApplicationRecord
  has_secure_password
  before_save :downcase_email
  ACCOUNT_PARAMS = %i(user_name email phone
                      password password_confirmation).freeze

  enum role: {user: 0, admin: 1}, _prefix: true
  VALID_EMAIL_REGEX = Regexp.new(Settings.value.valid_email)
  VALID_PHONE_REGEX = Regexp.new(Settings.value.phone_format)

  validates :user_name, presence: true,
    length: {maximum: Settings.value.max_user_name}
  validates :email, presence: true,
    length: {maximum: Settings.value.max_user_email},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: true
  validates :password, presence: true,
    length: {minimum: Settings.value.min_user_password},
    allow_nil: true
  validates :phone,
            length: {is: Settings.value.phone},
            format: {with: VALID_PHONE_REGEX}

  has_many :addresses, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_one_attached :image
  attr_accessor :remember_token

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_column :remember_digest, nil
  end

  private

  def downcase_email
    email.downcase!
  end
end
