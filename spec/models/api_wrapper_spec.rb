require "rails_helper"

RSpec.describe ApiWrapper, type: :model do
  let(:current_user) { create(:user) }
  let(:api_wrapper) { ApiWrapper.new(current_user) }
  let(:api_host) { CatarseSettings[:api_host] }

  context 'without user' do
    let(:current_user) { nil }

    describe '#jwt' do
      it { expect { api_wrapper.jwt }.to raise_error('no privileges') }
    end

    describe '#base_headers' do
      subject { api_wrapper.base_headers }
      it do
        is_expected.to eq(
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        )
      end
    end

    describe '#claims' do
      it { expect { api_wrapper.claims }.to raise_error('no privileges') }
    end

    describe '#request' do
      subject do
        api_wrapper.request(
          'project_details',
          params: {
            project_id: 'eq.10'
          },
          action: :get)
      end

      it { expect(subject.base_url).to eq("#{api_host}/project_details") }
      it { expect(subject.options[:method]).to eq(:get) }
      it { expect(subject.options[:headers]['Authorization']).to eq(nil) }
      it { expect(subject.options[:params]).to eq(project_id: 'eq.10') }
    end
  end

  context 'with current_user' do
    describe '#jwt' do
      subject { api_wrapper.jwt }
      it { is_expected.not_to be_nil }
    end

    describe '#request' do
      subject do
        api_wrapper.request(
          'project_details',
          params: {
            project_id: 'eq.10'
          },
          action: :get)
      end

      it { expect(subject.base_url).to eq("#{api_host}/project_details") }
      it { expect(subject.options[:method]).to eq(:get) }
      it { expect(subject.options[:headers]['Authorization']).to eq("Bearer #{api_wrapper.jwt}") }
      it { expect(subject.options[:params]).to eq(project_id: 'eq.10') }
    end

    describe '#base_headers' do
      subject { api_wrapper.base_headers }
      it do
        is_expected.to eq(
          'Authorization' => "Bearer #{api_wrapper.jwt}",
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        )
      end
    end

    describe '#claims' do
      subject { api_wrapper.claims }
      it do
        is_expected.to eq(
          role: 'web_user',
          user_id: current_user.id.to_s,
          exp: (Time.now + ApiWrapper::TOKEN_TTL).to_i
        )
      end
    end
  end
end
