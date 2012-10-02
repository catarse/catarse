require 'spec_helper'
describe PaymentStreamController do
  render_views
  subject{ response }

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
