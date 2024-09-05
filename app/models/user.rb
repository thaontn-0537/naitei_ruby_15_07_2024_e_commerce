class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  before_save :downcase_email
  ACCOUNT_PARAMS = %i(user_name email phone
                      password password_confirmation
                      remember_me).freeze

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

  def self.ransackable_attributes _auth_object = nil
    %w(
      created_at
      email
      id
      phone
      role
      updated_at
      user_name
    )
  end

  def self.ransackable_associations _auth_object = nil
    %w(
      addresses
      image_attachment
      image_blob
      orders
    )
  end

  private

  def downcase_email
    email.downcase!
  end
end
