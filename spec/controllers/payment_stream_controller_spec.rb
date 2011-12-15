require 'spec_helper'
describe PaymentStreamController do
  render_views
  
  describe '/moip' do
    it "should confirm backer in moip payment" do
      backer = Factory(:backer, :confirmed => false)
      post :moip, post_moip_params.merge!({:id_transacao => backer.key, :status_pagamento => '1', :valor => backer.moip_value})
      response.should be_successful
      backer.reload.confirmed.should be_true
    end

    it "should not confirm in case of error in moip payment" do
      backer = Factory(:backer, :confirmed => false)
      post :moip, post_moip_params.merge!({:id_transacao => -1, :status_pagamento => '1', :valor => backer.moip_value})
      response.should_not be_successful
      backer.reload.confirmed.should_not be_true
    end

    it "should return 422 when moip params is empty" do
      post :moip, {}
      response.should_not be_successful
      response.code.should == '422'
    end

    context "when have a payment detail" do
      before(:each) do
        project=create(:project)
        @backer=create(:backer, :payment_token => 'ABCD', :project => project, :confirmed => false)
        create(:payment_detail, :backer => @backer)
        @backer.reload
      end

      context 'when receive aonther moip request' do
        before(:each) do
          moip_response = moip_query_response.dup
          moip_response["Autorizacao"]["Pagamento"].merge!("Status" => 'BoletoPago')
          MoIP::Client.stubs(:query).with('ABCD').returns(moip_response)
        end

        it 'should update info and confirm backer' do
          @backer.confirmed.should_not be_true
          @backer.payment_detail.payment_status.should == 'BoletoImpresso'

          post :moip, post_moip_params.merge!({:id_transacao => @backer.key, :status_pagamento => '1', :valor => @backer.moip_value})

          @backer.reload
          @backer.payment_detail.payment_status.should == 'BoletoPago'
          @backer.confirmed.should be_true
        end

        it "when confirmed backer don't update the backer payment detail" do
          @backer.update_attribute :confirmed, true
          @backer.reload
          @backer.confirmed.should be_true
          @backer.payment_detail.payment_status.should == 'BoletoImpresso'

          post :moip, post_moip_params.merge!({:id_transacao => @backer.key, :status_pagamento => '1', :valor => @backer.moip_value})

          @backer.reload
          @backer.payment_detail.payment_status.should == 'BoletoImpresso'
        end
      end
    end
  end

  describe '/thank_you' do
    it "without project / session, should redirect" do
      request.session[:thank_you_id]=nil
      get :thank_you, :locale => :pt
      request.flash[:failure].should == I18n.t('payment_stream.thank_you.error')
      response.should be_redirect
    end

    it "with project / session, should not redirect" do
      project=create(:project)
      request.session[:thank_you_id] = project.id
      get :thank_you, :locale => :pt

      response.should render_template("payment_stream/thank_you")
      response.should be_success
      response.should_not be_redirect
      response.body.should =~ /#{I18n.t('payment_stream.thank_you.title')}/
      response.body.should =~ /#{I18n.t('payment_stream.thank_you.header_title')}/
      response.body.should =~ /#{I18n.t('payment_stream.thank_you.header_subtitle')}/
    end

    it 'with token session should create payment detail for backer' do
      project=create(:project)
      backer=create(:backer, :payment_token => 'ABCD', :project => project)
      request.session[:_payment_token] = 'ABCD'
      request.session[:thank_you_id] = project.id
      MoIP::Client.stubs(:query).returns(moip_query_response)
      backer.payment_detail.should be_nil

      get :thank_you, :locale => :pt
      response.should render_template("payment_stream/thank_you")
      response.should be_success
      backer.reload.payment_detail.should_not be_nil
    end

    it 'when moip_response should have a array in payment information' do
      project=create(:project)
      backer=create(:backer, :payment_token => 'ABCD', :project => project)
      request.session[:_payment_token] = 'ABCD'
      request.session[:thank_you_id] = project.id
      MoIP::Client.stubs(:query).returns(moip_query_response_with_array)
      backer.payment_detail.should be_nil

      get :thank_you, :locale => :pt
      response.should render_template("payment_stream/thank_you")
      response.should be_success
      backer.reload.payment_detail.should_not be_nil
    end

  end
end
