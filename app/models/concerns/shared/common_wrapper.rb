# frozen_string_literal: true

module Shared::CommonWrapper
  extend ActiveSupport::Concern

  included do
    def common_wrapper
      return unless CatarseSettings[:common_api_key].present? || CatarseSettings[:common_proxy_api_key]
      @common_wrapper ||= ::CommonWrapper.new
    end
  end
end
