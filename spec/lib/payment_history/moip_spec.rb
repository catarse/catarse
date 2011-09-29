require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe PaymentHistory::Moip do
  it 'Transaction status enum' do
    transaction = PaymentHistory::Moip::TransactionStatus
    transaction::AUTHORIZED.should      ==  1
    transaction::STARTED.should         ==  2
    transaction::PRINTED_BOLETO.should  ==  3
    transaction::FINISHED.should        ==  4
    transaction::CANCELED.should        ==  5
    transaction::PROCESS.should         ==  6
    transaction::WRITTEN_BACK.should    ==  7
  end

end