module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups
    module PreppendInputText
      # Name of the component method
      def preppend_input_text(wrapper_options = nil)
        @preppend_input_text ||= begin
          options[:preppend_input_text].to_s.html_safe if options[:preppend_input_text].present?
        end
      end

      # Used when the validation_text is optional
      def has_preppend_input_text?
        has_preppend_input_text.present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::PreppendInputText)

