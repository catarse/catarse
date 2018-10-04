# frozen_string_literal: true

module Shared::CommonWrapper
  extend ActiveSupport::Concern

  included do
    def common_wrapper
      @common_wrapper ||= ::CommonWrapper.new
    end
  end
end
