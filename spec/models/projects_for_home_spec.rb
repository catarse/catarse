require 'spec_helper'

describe ProjectsForHome do
  describe '.recommends' do
    before do
      4.times { create(:project, recommended: true, state: 'online') }
      @not_recommended_01 = create(:project, recommended: false, state: 'online')
    end

    subject { ProjectsForHome.recommends }

    it { should have(3).itens }
    it { should_not include(@not_recommended_01) }
  end

  describe '.recents' do
    before do
      4.times { create(:project, recommended: false, state: 'online', online_date: 4.days.ago ) }
      @not_recents_01 = create(:project, state: 'online', online_date: 6.days.ago)
    end

    subject { ProjectsForHome.recents }

    it { should have(3).itens }
    it { should_not include(@not_recents_01) }
  end

  describe '.expiring' do
    before do
      4.times { create(:project, recommended: false, state: 'online', online_days: 10, online_date: 6.days.ago ) }
      @not_expiring_01 = create(:project, recommended: false, state: 'online', online_days: 50, online_date: 2.days.ago)
    end

    subject { ProjectsForHome.expiring }

    it { should have(3).itens }
    it { should_not include(@not_expiring_01) }
  end

  describe "to_partial_path" do
    subject{ ProjectsForHome.new.to_partial_path }
    it{ should == 'projects/project' }
  end
end
