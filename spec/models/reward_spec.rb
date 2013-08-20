# coding: utf-8

require 'spec_helper'

describe Reward do
  let(:reward){ FactoryGirl.create(:reward, description: 'envie um email para foo@bar.com') }

  describe "Versioning" do
    subject { reward.versions }

    context 'when reward is recent' do
      it { should have(1).item }
      it("#has_modification?") { reward.has_modification?.should be_false }
    end

    context 'after update reward' do
      before { reward.update_attributes(description: 'just updated') }
      it { should have(2).itens }
      it { reward.last_description.should == "<p>envie um email para <a href=\"mailto:foo@bar.com\" target=\"_blank\">foo@bar.com</a></p>" }
      it("#has_modification?") { reward.has_modification?.should be_true }
    end
  end

  describe "Associations" do
    it{ should belong_to :project }
    it{ should have_many :backers }
  end

  describe "#display_description" do
    subject{ reward.display_description }
    it{ should == "<p>envie um email para <a href=\"mailto:foo@bar.com\" target=\"_blank\">foo@bar.com</a></p>" }
  end

  it "should have a minimum value" do
    r = FactoryGirl.build(:reward, minimum_value: nil)
    r.should_not be_valid
  end

  it "should have a display_minimum" do
    r = FactoryGirl.build(:reward)
    r.minimum_value = 10
    r.display_minimum.should == "R$ 10"
    r.minimum_value = 99
    r.display_minimum.should == "R$ 99"
  end

  it "should have a greater than 10.00 minimum value" do
    r = FactoryGirl.build(:reward)
    r.minimum_value = -0.01
    r.should_not be_valid
    r.minimum_value = 9.99
    r.should_not be_valid
    r.minimum_value = 10.00
    r.should be_valid
    r.minimum_value = 10.01
    r.should be_valid
  end

  it "should have a description" do
    r = FactoryGirl.build(:reward, description: nil)
    r.should_not be_valid
  end

  it "should have integer maximum backers" do
    r = FactoryGirl.build(:reward)
    r.maximum_backers = 10.01
    r.should_not be_valid
    r.maximum_backers = 10
    r.should be_valid
  end

  it "should have maximum backers > 0" do
    r = FactoryGirl.build(:reward)
    r.maximum_backers = -1
    r.should_not be_valid
    r.maximum_backers = 0
    r.should_not be_valid
    r.maximum_backers = 1
    r.should be_valid
  end

  describe '#sold_out?' do
    let(:reward) { FactoryGirl.create(:reward, maximum_backers: nil) }
    subject { reward.sold_out? }

    context 'when reward not have limits' do
      it { should be_false }
    end

    context 'when reward have limit' do
      let(:reward) { FactoryGirl.create(:reward, maximum_backers: 3) }

      context 'and have confirmed backers and backers in time to confirm' do
        before do
           FactoryGirl.create(:backer, state: 'confirmed', reward: reward, project: reward.project)
           FactoryGirl.create(:backer, state: 'waiting_confirmation', reward: reward, project: reward.project)
        end

        it { should be_false }
        it { reward.remaining.should == 1 }
      end

      context 'and have confirmed backers and the in time to confirm already expired' do
        before do
           FactoryGirl.create(:backer, state: 'confirmed', reward: reward, project: reward.project)
           FactoryGirl.create(:backer, state: 'pending', payment_token: 'ABC', reward: reward, project: reward.project, created_at: 8.days.ago)
        end

        it { should be_false }
        it { reward.remaining.should == 2 }
      end

      context 'and reached the maximum backers number with confirmed backers' do
        before do
           3.times { FactoryGirl.create(:backer, state: 'confirmed', reward: reward, project: reward.project) }
        end

        it { should be_true }
        it { reward.remaining.should == 0 }
      end

      context 'and reached the maximum backers number with backers in time to confirm' do
        before do
           3.times { FactoryGirl.create(:backer, state: 'waiting_confirmation', reward: reward, project: reward.project) }
        end

        it { should be_true }
        it { reward.remaining.should == 0 }
      end
    end
  end

  it "should have a HTML-safe name that is a HTML composition from minimum_value, description and sold_out" do
    I18n.locale = :pt
    r = FactoryGirl.build(:reward, minimum_value: 0, description: "Description", maximum_backers: 0)
    r.name.should == "<div class='reward_minimum_value'>Não quero recompensa</div><div class='reward_description'>Description</div><div class=\"sold_out\">Esgotada</div><div class='clear'></div>"
    r.maximum_backers = 1
    r.name.should == "<div class='reward_minimum_value'>Não quero recompensa</div><div class='reward_description'>Description</div><div class='clear'></div>"
    r.minimum_value = 10
    r.name.should == "<div class='reward_minimum_value'>R$ 10+</div><div class='reward_description'>Description</div><div class='clear'></div>"
    r.description = "Description<javascript>XSS()</javascript>"
    r.name.should == "<div class='reward_minimum_value'>R$ 10+</div><div class='reward_description'>Description&lt;javascript&gt;XSS()&lt;/javascript&gt;</div><div class='clear'></div>"
  end
end
