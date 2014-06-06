# Rails 4.1.0 and StateMachine don't play nice
# https://github.com/pluginaweek/state_machine/issues/295

require 'state_machine/version'

unless StateMachine::VERSION == '1.2.0'
  # If you see this message, please test removing this file
  # If it's still required, please bump up the version above
  Rails.logger.warn "Please remove me, StateMachine version has changed"
end

module StateMachine::Integrations::ActiveModel
  public :around_validation
end
