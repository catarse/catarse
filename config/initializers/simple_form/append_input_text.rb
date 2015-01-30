module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups
    module AppendInputText
      # Name of the component method
      def append_input_text(wrapper_options = nil)
        @append_input_text ||= begin
          options[:append_input_text].to_s.html_safe if options[:append_input_text].present?
        end
      end

      # Used when the validation_text is optional
      def has_append_input_text?
        has_append_input_textpresent?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::AppendInputText)


