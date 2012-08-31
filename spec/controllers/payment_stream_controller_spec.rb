require 'spec_helper'
describe PaymentStreamController do
  render_views
  subject{ response }

  describe 'POST /moip' do
    before do
      dummy_params = {'testing' => true}
      dummy_moip.expects(:process_request!).returns(dummy_moip)
      PaymentHistory::Moip.expects(:new).with(dummy_params.merge('controller' => 'payment_stream', 'action' => 'moip')).returns(dummy_moip)
      post :moip, dummy_params
    end

    context "when moip's response_code is not successful" do
      let(:dummy_moip){ stub(:process_request! => nil, :response_code => 500) }
      it{ should_not be_successful }
    end

    context "when moip's response_code is successful" do
      let(:dummy_moip){ stub(:process_request! => nil, :response_code => 200) }
      it{ should be_successful }
    end
  end

  describe 'GET /thank_you' do
    context "when we do not have a without project / session" do
      before do
        request.session[:thank_you_id]=nil
        get :thank_you, :locale => :pt
      end

      it{ should be_redirect }

      it "should show failure flash" do
        request.flash[:failure].should == I18n.t('payment_stream.thank_you.error')
      end
    end

    context "when we do have a project / session" do
      before do
        project = create(:project)
        request.session[:thank_you_id] = project.id
        get :thank_you, :locale => :pt
      end

      it{ should render_template("payment_stream/thank_you") }
      it{ should be_success }
      its(:body){ should =~ /#{I18n.t('payment_stream.thank_you.title')}/ }
    end

  end
end
