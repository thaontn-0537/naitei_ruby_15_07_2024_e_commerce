require "rails_helper"

RSpec.describe User, type: :model do
  describe "attribute validations" do
    describe "valid build" do
      subject {build(:user)}
      it {is_expected.to be_valid}
    end

    describe "#user_name" do
      it {is_expected.to validate_presence_of(:user_name)}
      it {is_expected.to validate_length_of(:user_name).is_at_most(50)}
    end

    describe "#email" do
      it {is_expected.to validate_length_of(:email).is_at_most(255)}
      it {is_expected.to validate_presence_of(:email)}

      it {is_expected.to allow_value("user@example.com").for(:email)}
      it {is_expected.to_not allow_value("userexamplecom").for(:email)}
      it {is_expected.to_not allow_value("userexample.com").for(:email)}
      it {is_expected.to_not allow_value("user@com").for(:email)}
      it {is_expected.to validate_length_of(:phone).is_equal_to(10)}
    end

    describe "#password" do
      it {is_expected.to validate_presence_of(:password)}
      it {is_expected.to validate_length_of(:password).is_at_least(8)}
    end

    describe "#phone" do
      it {is_expected.to validate_presence_of(:phone)}
      it {is_expected.to allow_value("0766257688").for(:phone)}
      it {is_expected.to_not allow_value("o766257688").for(:phone)}
    end
  end

  describe "associations" do
    describe "should have many" do
      it {should have_many(:addresses).dependent(:destroy)}
      it {should have_many(:carts).dependent(:destroy)}
      it {should have_many(:orders).dependent(:nullify)}
      it {should have_many(:feedbacks).dependent(:destroy)}
    end

    describe "should have one" do
      it {should have_one_attached(:image)}
    end
  end

  describe ".ransackable_attributes" do
    it "returns correct ransackable attributes" do
      expected_attributes = %w(
        created_at
        email
        id
        phone
        role
        updated_at
        user_name
      )
      expect(User.ransackable_attributes).to match_array(expected_attributes)
    end
  end

  describe ".ransackable_associations" do
    it "returns correct ransackable associations" do
      expected_associations = %w(
        addresses
        image_attachment
        image_blob
        orders
      )
      expect(User.ransackable_associations).to match_array(expected_associations)
    end
  end

  describe "callbacks" do
    it "downcases email before saving" do
      user = build(:user, email: "TeSt@ExAmPlE.Com")
      user.save
      expect(user.email).to eq("test@example.com")
    end
  end
end
