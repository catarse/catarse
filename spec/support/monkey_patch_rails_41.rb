if RUBY_VERSION >= "2.6.0"
  if Rails.version < "5"
    module MonitorMixin
      def mon_initialize
        if defined?(@mon_data)
          if defined?(@mon_initialized_by_new_cond)
            return # already initialized.
          end
        end
        @mon_data = ::Monitor.new
        @mon_data_owner_object_id = self.object_id
      end
    end
  end
end
