require 'spec_helper'

describe UserObserver do

  context "before create" do
    subject { create(:user, newsletter: false) }

    its(:newsletter) { should be_true }
  end

  context 'before_save' do
    subject { create(:user, twitter: '@should_be_change') }

    its(:twitter) { should == 'should_be_change' }
  end
end
