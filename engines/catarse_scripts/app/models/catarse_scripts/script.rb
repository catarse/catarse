module CatarseScripts
  class Script < ApplicationRecord
    self.table_name = :scripts

    enum status: { pending: 0, running: 1, done: 2, with_error: 3 }

    belongs_to :creator, class_name: 'User'
    belongs_to :executor, class_name: 'User', optional: true

    validates :creator_id, presence: true
    validates :status, presence: true
    validates :title, presence: true
    validates :description, presence: true
    validates :code, presence: true
    validates :class_name, presence: true

    validates :class_name, uniqueness: true

    validates :title, length: { maximum: 128 }
    validates :description, length: { maximum: 512 }
    validates :code, length: { maximum: 32768 }
    validates :ticket_url, length: { maximum: 512 }
    validates :class_name, length: { maximum: 512 }

    before_validation :generate_class_name, on: :create
    before_save :replace_code_class_name
    before_update :update_script_with_error_to_pending

    def generate_class_name
      timestamp = Time.zone.now.strftime('%Y%m%d%H%M%S%L')
      self.class_name = "::TempScript#{timestamp}"
    end

    def replace_code_class_name
      code.gsub!('<ScriptClassName>', class_name)
    end

    def update_script_with_error_to_pending
      return if will_save_change_to_status?

      self.status = :pending if with_error?
    end
  end
end
