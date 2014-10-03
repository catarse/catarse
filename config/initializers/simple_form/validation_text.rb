module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups
    module ValidationTexts
      # Name of the component method
      def validation_text(wrapper_options = nil)
        options[:validation_text_html] = {data: {error_for: "#{object_name}_#{attribute_name}"}}
        @validation_text ||= begin
           " " + I18n.t("simple_form.validation_texts.#{object_name}.#{attribute_name}").html_safe if options[:validation_text]
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
