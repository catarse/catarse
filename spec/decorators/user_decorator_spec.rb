require 'rails_helper'

RSpec.describe UserDecorator do
  before(:all) do
    I18n.locale = :pt
  end

  describe "#display_name" do
    subject{ user.display_name }

    context "when we only have a full name" do
      let(:user){ create(:user, name: nil, full_name: "Full Name") }
      it{ is_expected.to eq('Full Name') }
    end

    context "when we have only a name" do
      let(:user){ create(:user, name: 'name') }
      it{ is_expected.to eq('name') }
    end

    context "when name is empty string" do
      let(:user){ create(:user, name: '', full_name: 'foo') }
      it{ is_expected.to eq('foo') }
    end

    context "when we have a name and a full name" do
      let(:user){ create(:user, name: 'name', full_name: 'full name') }
      it{ is_expected.to eq('name') }
    end

    context "when we have no name" do
      let(:user){ create(:user, name: nil) }
      it{ is_expected.to eq(I18n.t('user.no_name')) }
    end
  end

  describe "#display_image_html" do
    let(:user){ build(:user, image_url: 'http://image.jpg', uploaded_image: nil )}
    let(:options){ {width: 300, height: 300} }
    subject{ user.display_image_html(options) }
    it{ is_expected.to eq("<div class=\"avatar_wrapper\" style=\"width: #{options[:width]}px; height: #{options[:height]}px\"><img alt=\"User\" src=\"#{user.display_image}\" style=\"width: #{options[:width]}px; height: auto\" /></div>") }
  end

  describe "#display_image" do
    subject{ user.display_image }

    context "when we have an uploaded image" do
      let(:user){ build(:user, uploaded_image: 'image.png' )}
      before do
        image = double(url: 'image.png')
        allow(image).to receive(:thumb_avatar).and_return(image)
        allow(user).to receive(:uploaded_image).and_return(image)
      end
      it{ is_expected.to eq('image.png') }
    end

    context "when we have an image url" do
      let(:user){ build(:user, image_url: 'image.png') }
      it{ is_expected.to eq('image.png') }
    end

    context "when we have an email" do
      let(:user){ create(:user, image_url: nil, email: 'diogob@gmail.com') }
      it{ is_expected.to eq("https://gravatar.com/avatar/5e2a237dafbc45f79428fdda9c5024b1.jpg?default=#{CatarseSettings[:base_url]}/assets/user.png") }
    end
  end

  describe "#short_name" do
    subject { user = create(:user, name: 'My Name Is Lorem Ipsum Dolor Sit Amet') }
    its(:short_name) { should == 'My Name Is Lorem ...' }
  end

  describe "#medium_name" do
    subject { user = create(:user, name: 'My Name Is Lorem Ipsum Dolor Sit Amet And This Is a Bit Name I Think') }
    its(:medium_name) { should == 'My Name Is Lorem Ipsum Dolor Sit Amet A...' }
  end

  describe "#display_credits" do
    subject { create(:user) }
    its(:display_credits) { should == 'R$ 0'}
  end

  describe "#display_total_of_contributions" do
    subject { user = create(:user) }
    context "with confirmed contributions" do
      before do
        create(:contribution, state: 'confirmed', user: subject, value: 500.0)
      end
      its(:display_total_of_contributions) { should == 'R$ 500'}
    end
  end
end
