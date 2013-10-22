require 'state_machine'
module Shared
  module StateMachineHelpers
    extend ActiveSupport::Concern

    included do
      def self.state_names
        self.state_machine.states.map do |state|
          state.name if state.name != :deleted
        end.compact!
      end
    end
  end
end
