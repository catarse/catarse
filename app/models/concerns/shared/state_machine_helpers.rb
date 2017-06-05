# frozen_string_literal: true

require 'state_machines'
module Shared
  module StateMachineHelpers
    extend ActiveSupport::Concern

    included do
      def self.state_names
        state_machine.states.map(&:name)
      end
    end
  end
end
