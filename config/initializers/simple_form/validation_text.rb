module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups
    module ValidationTexts
      # Name of the component method
      def validation_text(wrapper_options = nil)
        options[:validation_text_html] = {data: {for: "#{object_name}_#{attribute_name}"}}
        @validation_text ||= begin
          options[:validation_text].to_s.html_safe if options[:validation_text].present?
        end
      end

      # Used when the validation_text is optional
      def has_validation_text?
        validation_text.present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::ValidationTexts)
