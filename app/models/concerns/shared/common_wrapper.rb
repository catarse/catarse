# frozen_string_literal: true

module Shared::CommonWrapper
  extend ActiveSupport::Concern

  included do
    def common_wrapper
      common_api_key = CatarseSettings[:common_api_key]
      return unless common_api_key.present?
      @common_wrapper ||= ::CommonWrapper.new(common_api_key)
    end
  end
end
