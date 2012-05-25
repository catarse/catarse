require 'spec_helper'
describe PaypalController do

  shared_examples :failure_flash do
    it("should set failure flash"){ flash[:failure].should == I18n.t('projects.backers.checkout.paypal_error') }
  end
  shared_examples(:success_flash) do
    it("should set success flash"){ flash[:success].should == I18n.t('projects.backers.checkout.success') }
  end
  shared_examples(:cancel_flash) do
    it("should set cancel flash"){ flash[:failure].should == I18n.t('projects.backers.checkout.paypal_cancel') }
  end
  shared_examples :redirect_back_to_payment do
    it{ should redirect_to(new_project_backer_path(@backer.project)) }
  end

  # Just to simplify mocking the class in the descriptions.
  let(:payment_class){ ActiveMerchant::Billing::PaypalAdaptivePayment }

  render_views
  subject{ response }


  before{
    # For some weird reason FactoryGirl generates a problem
    # in a uniqueness validation that I can't track down...
    # So I've put this clean here to fix thing.
    DatabaseCleaner.clean
    @backer = Factory(:backer, confirmed: false)
  }

  describe 'GET /pay' do
    before{ payment_class.any_instance.stubs(:setup_purchase).returns(response) }

    describe "success" do
      let(:response){ mock({success?: true, pay_key: "12345"}) }
      before{
        payment_class.any_instance.stubs(:redirect_url_for).with("12345").returns("https://paypal.com/ok")
        get :pay, id: @backer.id, locale: :pt
      }      
      it{ should redirect_to("https://paypal.com/ok") }
      it("backer should pay with PayPal"){ @backer.reload.payment_method.should == 'PayPal' }
    end
    describe "failure" do
      let(:response){ mock({success?: false}) }
      before{ get :pay, id: @backer.id, locale: :pt }
      include_examples :redirect_back_to_payment
      include_examples :failure_flash
    end
  end

  describe 'GET /success' do
    describe "success" do
      before{
        request = mock()
        payer = mock({identifier: "123"})
        details = mock({payer: payer})
        request.stubs(:details).with("abc").returns(details)

        info = mock(payment_status: "Completed", transaction_id: "99887766")
        checkout = mock({payment_info: [info]})
        request.stubs(:checkout!).returns(checkout)
        Paypal::Express::Request.stubs(:new).returns(request)
        get :success, id: @backer.id, locale: :pt, token: "abc"
        @backer.reload
      }      
      it{ should redirect_to(thank_you_path) }
      it("backer should be confirmed"){ @backer.should be_confirmed }    
      it("backer should have the correct key"){ @backer.key.should == "99887766" }
      it("backer should have the correct payment_token"){ @backer.payment_token.should == "abc" }
      include_examples :success_flash
    end
    describe "failure" do
      before{
        request = mock()
        payer = mock({identifier: "123"})
        details = mock({payer: payer})
        request.stubs(:details).with("abc").returns(details)

        info = mock(payment_status: "Error")
        checkout = mock({payment_info: [info]})
        request.stubs(:checkout!).returns(checkout)
        Paypal::Express::Request.stubs(:new).returns(request)
        get :success, id: @backer.id, locale: :pt, token: "abc"
        @backer.reload
      }      
      it("backer should not be confirmed"){ @backer.should_not be_confirmed }    
      include_examples :redirect_back_to_payment
      include_examples :failure_flash
    end
    describe "failure with exception" do
      before{
        request = mock()
        request.stubs(:details).with("abc").raises
        Paypal::Express::Request.stubs(:new).returns(request)
        get :success, id: @backer.id, locale: :pt, token: "abc"
        @backer.reload
      }      
      it("backer should not be confirmed"){ @backer.should_not be_confirmed }    
      include_examples :redirect_back_to_payment
      include_examples :failure_flash
    end
  end

  describe 'GET /cancel' do
    describe "success" do
      before{
        get :cancel, id: @backer.id, locale: :pt
        @backer.reload
      }
      include_examples :cancel_flash
      include_examples :redirect_back_to_payment
    end
  end

end