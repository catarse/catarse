require 'spec_helper'

describe Unsubscribe do
  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :project }
  end

  describe ".by_project_id" do
    let(:project_01) { create(:project) }
    let(:project_02) { create(:project) }

    subject { Unsubscribe.by_project_id(project_01.id)}

    before do
      create(:unsubscribe, project: project_01)
      create(:unsubscribe, project: project_01)
      create(:unsubscribe, project: project_02)
    end

    it { should have(2).itens }
  end

  describe '.drop_all_for_project' do
    let(:project_01) { create(:project) }
    let(:project_02) { create(:project) }

    subject { Unsubscribe.count() }

    before do
      create(:unsubscribe, project: project_01)
      create(:unsubscribe, project: project_01)
      create(:unsubscribe, project: project_02)

      Unsubscribe.drop_all_for_project(project_01.id)
    end

    it { should == 1 }
  end

  describe ".posts_unsubscribe" do
    subject{ Unsubscribe.posts_unsubscribe(1618) }
    it{ should_not be_persisted }
    its(:class){ should == Unsubscribe }
    its(:project_id){ should == 1618 }

    context "when project_id is nil" do
      subject{ Unsubscribe.posts_unsubscribe(nil) }
      its(:class){ should == Unsubscribe }
      its(:project_id){ should be_nil }
    end
  end
end
