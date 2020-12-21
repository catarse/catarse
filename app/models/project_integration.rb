# coding: utf-8
# frozen_string_literal: true

class ProjectIntegration < ApplicationRecord

    INTEGRATIONS_AVAILABLE = %w[GA PIXEL SOLIDARITY_SERVICE_FEE]

    include I18n::Alchemy

    belongs_to :project

    validates :name, inclusion: { in: INTEGRATIONS_AVAILABLE }
end
