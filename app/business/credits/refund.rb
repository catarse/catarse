module Credits
  class Refund
    attr_accessor :backer, :user, :message

    def initialize(backer, user)
      @backer = backer
      @user = user
    end

    def make_request!
      check_refunded
      check_requested
      check_total_of_credits
      check_can_refund
      @backer.update_attributes({ requested_refund: true })
      @backer.user.credits = @backer.user.credits - @backer.value
      @backer.user.save
      CreditsMailer.request_refund_from(@backer).deliver
      @message = I18n.t('credits.index.refunded')
    end

    private

    def check_requested
      raise I18n.t('credits.refund.requested_refund') if @backer.requested_refund
    end

    def check_refunded
      raise I18n.t('credits.refund.refunded') if @backer.refunded
    end

    def check_total_of_credits
      unless @backer.user.credits >= @backer.value
        raise I18n.t('credits.refund.no_credits')
      end
    end

    def check_can_refund
      raise I18n.t('credits.refund.cannot_refund') unless @backer.can_refund
    end
  end
end
