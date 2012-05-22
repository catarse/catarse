require 'spec_helper'
describe PaypalController do
  render_views
  subject{ response }

  describe 'GET /pay' do
    before{
      ActiveMerchant::Billing::PaypalAdaptivePayment.any_instance.stubs(:setup_purchase).returns({"payKey" => "12345"})
      ActiveMerchant::Billing::PaypalAdaptivePayment.any_instance.stubs(:redirect_url_for).with("12345").returns("https://paypal.com/ok")

      backer = Factory(:backer, confirmed: false)
      get :pay, id: backer.id, locale: :pt
    }      
    it{ should redirect_to("https://paypal.com/ok") }

  end

  describe 'GET /success' do
    # let( }
    before{
      ActiveMerchant::Billing::PaypalAdaptivePayment.any_instance.stubs(:setup_purchase).returns({"payKey" => "12345"})
      ActiveMerchant::Billing::PaypalAdaptivePayment.any_instance.stubs(:redirect_url_for).with("12345").returns("https://paypal.com/ok")
      @backer = Factory(:backer, confirmed: false)
      get :success, id: @backer.id, locale: :pt
    }      
    it("backer should be confirmed"){ @backer.reload; @backer.should be_confirmed }
    it{ should redirect_to(thank_you_path) }
    

  end

end
