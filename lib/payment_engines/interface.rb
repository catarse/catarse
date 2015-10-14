class PaymentEngines
  class Interface

    def name; end

    def locale; end

    def review_path(contribution); end

    def can_do_refund?; end

    def direct_refund(contribution); end

    def transfer(contribution); end

    def can_generate_second_slip?; end

    def second_slip_path(contribution); end

  end
end
