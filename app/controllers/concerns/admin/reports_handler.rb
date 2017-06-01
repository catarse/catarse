# frozen_string_literal: true

module Concerns::Admin::ReportsHandler
  extend ActiveSupport::Concern

  included do
    inherit_resources
    responders :csv
    respond_to :csv
  end
end
