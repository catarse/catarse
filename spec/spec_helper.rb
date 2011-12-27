# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Factory::Syntax::Methods
  config.include ActionView::Helpers::TextHelper

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    ActiveRecord::Base.connection.execute "SET client_min_messages TO warning;"
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    Project.any_instance.stubs(:verify_if_video_exists_on_vimeo).returns(true)
    Project.any_instance.stubs(:store_image_url).returns('http://www.store_image_url.com')

    DatabaseCleaner.clean
  end

  def mock_tumblr method=:two
    require "#{Rails.root}/spec/fixtures/tumblr_data" # just a fixture
    Tumblr::Post.stubs(:all).returns(TumblrData.send(method))
  end
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.configure do |config|
 config.default_driver = defined?(Capybara::Driver::Webkit) ? :webkit : :selenium
 config.ignore_hidden_elements = false
 # config.seletor :css
 config.server_port = 8200
 config.app_host = "http://localhost:8200"
end

def post_moip_params
  {
    :id_transacao => 'ABCD',
    :valor => 2190, #=> R$ 21,90
    :status_pagamento => 3,
    :cod_moip => 12345123,
    :forma_pagamento => 1,
    :tipo_pagamento => 'CartaoDeCredito',
    :email_consumidor => 'some@email.com'
  }
end

def moip_query_response
  {
    "ID"=>"201109300946542390000012428473", "Status"=>"Sucesso",
    "Autorizacao"=>{
      "Pagador"=>{
        "Nome"=>"Lorem Ipsum", "Email"=>"some@email.com"
      },
      "EnderecoCobranca"=>{
        "Logradouro"=>"Some Address ,999", "Numero"=>"999",
        "Complemento"=>"Address A", "Bairro"=>"Hello World", "CEP"=>"99999-000",
        "Cidade"=>"Some City", "Estado"=>"MG", "Pais"=>"BRA",
        "TelefoneFixo"=>"(31)3666-6666"
      },
      "Recebedor"=>{
        "Nome"=>"Happy Guy", "Email"=>"happy@email.com"
      },
      "Pagamento"=>{
        "Data"=>"2011-09-30T09:33:37.000-03:00", "TotalPago"=>"999.00", "TaxaParaPagador"=>"0.00",
        "TaxaMoIP"=>"19.37", "ValorLiquido"=>"979.63", "FormaPagamento"=>"BoletoBancario",
        "InstituicaoPagamento"=>"Itau", "Status"=>"BoletoImpresso", "CodigoMoIP"=>"0000.0728.5285"
      }
    }
  }
end

def moip_query_response_with_array
  {
    "ID"=>"201109300946542390000012428473", "Status"=>"Sucesso",
    "Autorizacao"=>{
      "Pagador"=>{
        "Nome"=>"Lorem Ipsum", "Email"=>"some@email.com"
      },
      "EnderecoCobranca"=>{
        "Logradouro"=>"Some Address ,999", "Numero"=>"999",
        "Complemento"=>"Address A", "Bairro"=>"Hello World", "CEP"=>"99999-000",
        "Cidade"=>"Some City", "Estado"=>"MG", "Pais"=>"BRA",
        "TelefoneFixo"=>"(31)3666-6666"
      },
      "Recebedor"=>{
        "Nome"=>"Happy Guy", "Email"=>"happy@email.com"
      },
      "Pagamento"=>[{
        "Data"=>"2011-09-30T09:33:37.000-03:00", "TotalPago"=>"999.00", "TaxaParaPagador"=>"0.00",
        "TaxaMoIP"=>"19.37", "ValorLiquido"=>"979.63", "FormaPagamento"=>"BoletoBancario",
        "InstituicaoPagamento"=>"Itau", "Status"=>"BoletoImpresso", "CodigoMoIP"=>"0000.0728.5285"
      }]
    }
  }
end

def paypal_transaction_details_fake_response
  "RECEIVEREMAIL=some%40email%2ecom&RECEIVERID=ABCD&
  EMAIL=customer%40gmail%2ecom&PAYERID=EFGH&
  PAYERSTATUS=unverified&COUNTRYCODE=GB&ADDRESSOWNER=PayPal&ADDRESSSTATUS=None&
  SALESTAX=0%2e00&SUBJECT=Apoio%20para%20projetoApoio%20para%20projeto&
  TIMESTAMP=2011%2d12%2d06T15%3a17%3a39Z&CORRELATIONID=1234&
  ACK=Success&VERSION=78%2e0&BUILD=2230381&FIRSTNAME=Lorem&LASTNAME=Ipsum&
  TRANSACTIONID=1234&TRANSACTIONTYPE=cart&PAYMENTTYPE=instant&
  ORDERTIME=2011%2d12%2d02T14%3a29%3a18Z&AMT=80%2e00&FEEAMT=5%2e72&
  TAXAMT=0%2e00&SHIPPINGAMT=0%2e00&HANDLINGAMT=0%2e00&CURRENCYCODE=BRL&
  PAYMENTSTATUS=Completed&PENDINGREASON=None&REASONCODE=None&
  PROTECTIONELIGIBILITY=Ineligible&PROTECTIONELIGIBILITYTYPE=None&
  L_NAME0=Loremipsumdolor&L_QTY0=1&
  L_SHIPPINGAMT0=0%2e00&L_HANDLINGAMT0=0%2e00&L_CURRENCYCODE0=BRL&L_AMT0=80%2e00"
end

class FakeResponse
  def code
    200
  end

  def body
    paypal_transaction_details_fake_response
  end
end

I18n.locale = :pt
I18n.default_locale = :pt