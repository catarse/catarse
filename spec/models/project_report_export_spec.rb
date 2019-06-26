require 'rails_helper'

RSpec.describe ProjectReportExport, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :project }
  end

  describe 'validations' do
    %w[project report_type report_type_ext].each do |field|
      it { is_expected.to validate_presence_of field }
    end

    it { is_expected.to validate_inclusion_of(:report_type).in_array(ProjectReportExport::REPORT_TYPE_LIST) }
    it { is_expected.to validate_inclusion_of(:report_type_ext).in_array(ProjectReportExport::REPORT_TYPE_EXT_LIST) }
  end

  describe 'fetch_report' do
    let(:resource) { create(:project_report_export, report_type: 'SubscriptionMonthlyReportForProjectOwner') }
    before do
      expect(SubscriptionMonthlyReportForProjectOwner).to receive(:project_id).with(resource.project.common_id).and_call_original
    end

    it 'should call report_type class report_method' do
      resource.fetch_report
    end
  end
end
