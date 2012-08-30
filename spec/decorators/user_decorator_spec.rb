require 'spec_helper'

describe UserDecorator do
  describe "#display_name" do
    subject{ user.display_name }

    context "when we have a name" do
      let(:user){ Factory(:user, :name => "Name") }
      it{ should == 'Name' }
    end

    context "when we have only a nickname" do
      let(:user){ Factory(:user, :name => nil, :nickname => 'nick') }
      it{ should == 'nick' }
    end

    context "when we have no name" do
      let(:user){ Factory(:user, :name => nil, :nickname => nil) }
      it{ should == I18n.t('user.no_name') }
    end
  end

  describe "#display_image" do
    subject{ user.display_image }

    context "when we have an uploaded image" do
      let(:user){ Factory.build(:user, :uploaded_image => 'image.png' )}
      before do
        image = stub(:url => 'image.png')
        user.stubs(:uploaded_image).returns(image)
      end
      it{ should == 'image.png' }
    end

    context "when we have an image url" do
      let(:user){ Factory.build(:user, :image_url => 'image.png') }
      it{ should == 'image.png' }
    end

    context "when we have an email" do
      let(:user){ Factory(:user, :image_url => nil, :email => 'diogob@gmail.com') }
      it{ should == "http://gravatar.com/avatar/5e2a237dafbc45f79428fdda9c5024b1.jpg?default=#{I18n.t('site.base_url')}/assets/user.png" }
    end

    context "when we do not have an image nor an email" do
      let(:user){ Factory(:user, :image_url => nil, :email => nil) }
      it{ should == '/assets/user.png' }
    end
  end

  describe "#short_name" do
    subject { user = Factory(:user, name: 'My Name Is Lorem Ipsum Dolor Sit Amet') }
    its(:short_name) { should == 'My Name Is Lorem Ipsum ...' }
  end

  describe "#medium_name" do
    subject { user = Factory(:user, name: 'My Name Is Lorem Ipsum Dolor Sit Amet And This Is a Bit Name I Think') }
    its(:medium_name) { should == 'My Name Is Lorem Ipsum Dolor Sit Amet A...' }
  end

  describe "#display_credits" do
    subject { Factory(:user) }
    its(:display_credits) { should == 'R$ 0'}
  end

  describe "#display_total_of_backs" do
    subject { user = Factory(:user) }
    context "with confirmed backs" do
      before do
        Factory(:backer, user: subject, value: 500.0)
      end
      its(:display_total_of_backs) { should == 'R$ 500'}
    end
  end
end
