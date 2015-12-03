require 'rails_helper'

RSpec.describe Origin, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:projects) }
    it { is_expected.to have_many(:contributions) }
  end

  describe "validations" do
    it{ is_expected.to validate_presence_of(:domain) }
    it { is_expected.to validate_uniqueness_of(:domain).scoped_to(:referral) }
  end

  describe "#process" do
    let(:domain) { nil }
    let(:referral) { nil }

    subject { Origin.process(referral, domain) }

    context "with ref" do
      context "when referral already exists into database with the same origin domain" do
        let(:domain) { 'www.catarse.me' }
        let(:referral) { 'explore' }
        let!(:origin) { create(:origin, domain: 'catarse.me', referral: referral)}
        it "should return the already created origin" do
          is_expected.to eq origin
        end
      end

      context "when referral should not exists" do
        let(:domain) { 'http://m.facebook.com/posts/123123/lorem' }
        let(:referral) { 'fb_test' }
        let!(:origin) { create(:origin, domain: 'lorem.com', referral: referral)}

        it "should store and return a new origin" do
          expect(subject.domain).to eq 'm.facebook.com'
          expect(subject).to_not eq(origin)
        end
      end
    end

    context "without ref" do
      let(:domain) { 'google.com' }
      let(:referral) { nil }
      it "should store without ref" do
        is_expected.to_not eq(nil)
        expect(subject.domain).to eq(domain)
      end
    end

    context "without origin domain" do
      let(:domain) { nil }
      it "should return nil without domain" do
        is_expected.to eq(nil)
      end
    end
  end
end
