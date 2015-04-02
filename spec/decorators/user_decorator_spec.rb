require 'rails_helper'

RSpec.describe UserDecorator do
  before(:all) do
    I18n.locale = :pt
  end

  describe "#display_name" do
    subject{ user.display_name }

    context "when we have only a name" do
      let(:user){ create(:user, name: 'name') }
      it{ is_expected.to eq('name') }
    end

    context "when we have no name" do
      let(:user){ create(:user, name: nil) }
      it{ is_expected.to eq(I18n.t('user.no_name')) }
    end
  end

  describe "#display_image_html" do
    let(:user){ build(:user, uploaded_image: nil )}
    let(:options){ {width: 300, height: 300} }
    subject{ user.display_image_html }
    it{ is_expected.to eq("<div class=\"avatar_wrapper\"><img alt=\"User\" class=\"thumb big u-round\" src=\"#{user.display_image}\" /></div>") }
  end

  describe "#display_image" do
    subject{ user.display_image }

    let(:user){ build(:user, uploaded_image: 'image.png' )}
    before do
      image = double(url: 'image.png')
      allow(image).to receive(:thumb_avatar).and_return(image)
      allow(user).to receive(:uploaded_image).and_return(image)
    end
    it{ is_expected.to eq('image.png') }

    end

  describe "#short_name" do
    subject { create(:user, name: 'My Name Is Lorem Ipsum Dolor Sit Amet') }
    its(:short_name) { should == 'My Name Is Lorem ...' }
  end

  describe "#medium_name" do
    subject { create(:user, name: 'My Name Is Lorem Ipsum Dolor Sit Amet And This Is a Bit Name I Think') }
    its(:medium_name) { should == 'My Name Is Lorem Ipsum Dolor Sit Amet A...' }
  end

  describe "#display_credits" do
    subject { create(:user) }
    its(:display_credits) { should == 'R$ 0'}
  end

  describe "#display_total_of_contributions" do
    subject { create(:user) }
    context "with confirmed contributions" do
      before do
        create(:confirmed_contribution, user: subject, value: 500.0)
      end
      its(:display_total_of_contributions) { should == 'R$ 500'}
    end
  end
end
