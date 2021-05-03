# frozen_string_literal: true

if Rails.env.test?
  module CarrierWave
    module Downloader
      class Base
        def skip_ssrf_protection?(_uri)
          true # SSRF protection isn't necessary because we avoid external requests with webmock
        end
      end
    end
  end
end
