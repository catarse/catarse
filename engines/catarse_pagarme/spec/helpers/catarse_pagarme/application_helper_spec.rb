# frozen_string_literal: true

require 'spec_helper'

describe CatarsePagarme::ApplicationHelper, type: :helper do
  before do
    installments_hash = {"installments"=>{"1"=>{"installment"=>1, "amount"=>10000, "installment_amount"=>10000}, "2"=>{"installment"=>2, "amount"=>10000, "installment_amount"=>5000}, "3"=>{"installment"=>3, "amount"=>10000, "installment_amount"=>3333}, "4"=>{"installment"=>4, "amount"=>10000, "installment_amount"=>2500}, "5"=>{"installment"=>5, "amount"=>10000, "installment_amount"=>2000}, "6"=>{"installment"=>6, "amount"=>10000, "installment_amount"=>1667}, "7"=>{"installment"=>7, "amount"=>10000, "installment_amount"=>1429}, "8"=>{"installment"=>8, "amount"=>10000, "installment_amount"=>1250}, "9"=>{"installment"=>9, "amount"=>10000, "installment_amount"=>1111}, "10"=>{"installment"=>10, "amount"=>10000, "installment_amount"=>1000}, "11"=>{"installment"=>11, "amount"=>10000, "installment_amount"=>909}, "12"=>{"installment"=>12, "amount"=>10000, "installment_amount"=>833}}}
    PagarMe::Transaction.stub(:calculate_installments).and_return(installments_hash)
    CatarsePagarme.configuration.stub(:max_installments).and_return(6)
  end

  let(:payment) { create(:payment, value: 100) }

  context "#installments_for_select" do
    subject { installments_for_select(payment) }
    it { expect(subject.size).to eq(3) }
    it { expect(subject[0][0]).to eq('1x $100.00 ') }
    it { expect(subject[0][1]).to eq(1) }
  end

  context '#format_instalment_text' do
    subject { format_instalment_text(4, 100.0) }
    it { expect(subject).to eq('4x $100.00') }
  end
end
