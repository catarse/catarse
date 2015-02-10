module Project::PaymentEngineHandler
  extend ActiveSupport::Concern

  included do
    scope :using_pagarme, -> (permalinks) do
      where("projects.permalink in (:permalinks) OR
           projects.online_date::date  AT TIME ZONE '#{Time.zone.tzinfo.name}' >= '2014-11-10'::date AT TIME ZONE '#{Time.zone.tzinfo.name}'",
           { permalinks: permalinks })
    end

    scope :not_using_pagarme, -> do
      where("projects.permalink not in (:permalinks) AND projects.online_date::date AT TIME ZONE '#{Time.zone.tzinfo.name}' < '2014-11-10'::date AT TIME ZONE '#{Time.zone.tzinfo.name}'",
            { permalinks: (CatarseSettings[:projects_enabled_to_use_pagarme].split(',').map(&:strip) rescue []) })
    end

    def self.enabled_to_use_pagarme
      permalinks = (CatarseSettings[:projects_enabled_to_use_pagarme].split(',').map(&:strip) rescue [])
      self.using_pagarme(permalinks)
    end

    def self.with_payment_engine(payment_engine_name)
      return enabled_to_use_pagarme if payment_engine_name == 'pagarme'
      return not_using_pagarme if payment_engine_name == 'moip'
      self
    end

    def using_pagarme?
      Project.enabled_to_use_pagarme.include?(self)
    end
  end
end
