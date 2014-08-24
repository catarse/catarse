require 'spec_helper'

describe Concerns::SocialHelpersHandler do
  render_views
  before do
    [:render_facebook_sdk, :render_facebook_like, :render_twitter].each do |method|
      ApplicationController.any_instance.unstub(method)
    end
    @controller = ApplicationController.new
  end

  describe '#fb_admins_add' do
    before { @controller.instance_variable_set(:@fb_admins, []) }

    context 'when is not an array' do
      it { expect(@controller.fb_admins_add(1)).to eq [1] }
    end

    context 'when is an array' do
      it { expect(@controller.fb_admins_add([1, 2])).to eq [1, 2] }
    end
  end

  describe '#fb_adminsd' do
    before { @controller.instance_variable_set(:@fb_admins, [1, 2, 3]) }

    it { expect(@controller.fb_admins).to eq '1,2,3' }
  end

  describe '#render_facebook_sdk' do
    it { expect(@controller.render_facebook_sdk).to render_template(partial: 'layouts/_facebook_sdk') }
  end

  describe '#render_twitter' do
    let(:options) { { url: 'http://test.local', text: 'Foo Bar' } }
    it { expect(@controller.render_twitter(options)).to render_template(partial: 'layouts/_twitter') }
  end

  describe '#render_facebook_like' do
    let(:options) { { width: 300, href: 'http://test.local' } }
    it { expect(@controller.render_facebook_like(options)).to render_template(partial: 'layouts/_facebook_like') }
  end

end
