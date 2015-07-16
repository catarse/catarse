# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Wrappers are used by the form builder to generate a
  # complete input. You can remove any component from the
  # wrapper, change the order or even add your own to the
  # stack. The options given below are used to wrap the
  # whole input.
  config.wrappers :input_with_error, class: :input,
    error_class: [:field_with_errors, :error] do |b|

    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.use :input, class: 'medium'
  end

  config.wrappers :one_col, class: :input,
    hint_class: :field_with_hint, error_class: [:field_with_errors, :error] do |b|

    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.use :label_text, wrap_with: { tag: :label, class: "field-label fontweight-semibold" }
    b.use :hint,  wrap_with: { tag: :label, class: 'hint fontsize-smallest fontcolor-secondary u-marginbottom-20'}

    b.use :input
    b.use :validation_text, wrap_with: { tag: :div, class: 'fontsize-smaller text-error u-marginbottom-20 fa fa-exclamation-triangle w-hidden' }
  end

  config.wrappers :two_columns, class: :input,
    hint_class: :field_with_hint, error_class: [:field_with_errors, :error] do |b|

    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.wrapper :label_wrapper, tag: 'div' do |ba|
      ba.use :label_text, wrap_with: { tag: :label, class: "field-label fontweight-semibold fontsize-base" }
      ba.use :hint,  wrap_with: { tag: :label, class: 'hint fontsize-smallest fontcolor-secondary'}
    end

    b.wrapper :text_field_wrapper, tag: 'div' do |ba|
      ba.use :input
      ba.use :validation_text, wrap_with: { tag: :div, class: 'fontsize-smaller text-error u-marginbottom-20 fa fa-exclamation-triangle w-hidden' }
    end
  end

  config.wrappers :two_columns_with_postfix, class: :input,
    hint_class: :field_with_hint, error_class: [:field_with_errors, :error] do |b|

    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.wrapper :label_wrapper, tag: 'div' do |ba|
      ba.use :label_text, wrap_with: { tag: :label, class: "field-label fontweight-semibold" }
      ba.use :hint,  wrap_with: { tag: :label, class: 'hint fontsize-smallest fontcolor-secondary'}
    end

    b.wrapper :text_field_wrapper, tag: 'div' do |ba|
      ba.wrapper tag: 'div', class: 'w-row' do |w_row|
        w_row.wrapper :preppend_text_wrapper, tag: 'div' do |preppend|
          preppend.wrapper :preppend_input_text_wrapper, tag: 'div', class: 'fontcolor-secondary u-text-center' do |p_wrapper|
            p_wrapper.use :preppend_input_text
          end
        end

        w_row.wrapper :field_wrapper do |field_wrapper|
          field_wrapper.use :input
          field_wrapper.use :validation_text, wrap_with: { tag: :div, class: 'fontsize-smaller text-error u-marginbottom-20 fa fa-exclamation-triangle w-hidden' }
        end

        w_row.wrapper :append_text_wrapper, tag: 'div' do |append|
          append.wrapper :append_input_text_wrapper, tag: 'div', class: 'fontcolor-secondary u-text-center' do |a_wrapper|
            a_wrapper.use :append_input_text
          end
        end
      end
    end
  end

  config.wrappers :default, class: :input,
    hint_class: :field_with_hint, error_class: [:field_with_errors, :error] do |b|
    ## Extensions enabled by default
    # Any of these extensions can be disabled for a
    # given input by passing: `f.input EXTENSION_NAME => false`.
    # You can make any of these extensions optional by
    # renaming `b.use` to `b.optional`.

    # Determines whether to use HTML5 (:email, :url, ...)
    # and required attributes
    b.use :html5

    # Calculates placeholders automatically from I18n
    # You can also pass a string as f.input placeholder: "Placeholder"
    b.use :placeholder

    ## Optional extensions
    # They are disabled unless you pass `f.input EXTENSION_NAME => :lookup`
    # to the input. If so, they will retrieve the values from the model
    # if any exists. If you want to enable the lookup for any of those
    # extensions by default, you can change `b.optional` to `b.use`.

    # Calculates maxlength from length validations for string inputs
    b.optional :maxlength

    # Calculates pattern from format validations for string inputs
    b.optional :pattern

    # Calculates min and max from length validations for numeric inputs
    b.optional :min_max

    # Calculates readonly automatically from readonly attributes
    b.optional :readonly

    ## Inputs
    # b.wrapper :tag => 'div', :class => 'controls' do |ba|
    #   ba.use :hint,  wrap_with: { tag: :span, class: :hint }
    #   ba.use :label_input
    #   ba.use :error, wrap_with: { tag: :span, class: :error }
    # end
    b.use :label_text, wrap_with: { tag: :label, class: "field-label" }
    b.use :hint,  wrap_with: { tag: :span, class: :hint }
    b.use :input
    b.use :validation_text, wrap_with: { tag: :div, class: 'fontsize-smaller text-error u-marginbottom-20 fa fa-exclamation-triangle w-hidden' }
    #b.use :error, wrap_with: { tag: :span, class: :error }
  end

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :default

  # Define the way to render check boxes / radio buttons with labels.
  # Defaults to :nested for bootstrap config.
  #   inline: input + label
  #   nested: label > input
  config.boolean_style = :nested

  # Default class for buttons
  config.button_class = 'btn'

  # Method used to tidy up errors. Specify any Rails Array method.
  # :first lists the first message for each field.
  # Use :to_sentence to list all errors for each field.
  # config.error_method = :first

  # Default tag used for error notification helper.
  config.error_notification_tag = :div

  # CSS class to add for error notification helper.
  config.error_notification_class = 'alert alert-error'

  # ID to add for error notification helper.
  # config.error_notification_id = nil

  # Series of attempts to detect a default label method for collection.
  # config.collection_label_methods = [ :to_label, :name, :title, :to_s ]

  # Series of attempts to detect a default value method for collection.
  # config.collection_value_methods = [ :id, :to_s ]

  # You can wrap a collection of radio/check boxes in a pre-defined tag, defaulting to none.
  # config.collection_wrapper_tag = nil

  # You can define the class to use on all collection wrappers. Defaulting to none.
  # config.collection_wrapper_class = nil

  # You can wrap each item in a collection of radio/check boxes with a tag,
  # defaulting to :span. Please note that when using :boolean_style = :nested,
  # SimpleForm will force this option to be a label.
  # config.item_wrapper_tag = :span

  # You can define a class to use in all item wrappers. Defaulting to none.
  # config.item_wrapper_class = nil

  # How the label text should be generated altogether with the required text.
  config.label_text = lambda { |label, required, explicit_label| label }

  # You can define the class to use on all labels. Default is nil.
  config.label_class = 'field-label'

  # You can define the class to use on all forms. Default is simple_form.
  # config.form_class = :simple_form

  # You can define which elements should obtain additional classes
  # config.generate_additional_classes_for = [:wrapper, :label, :input]

  # Whether attributes are required by default (or not). Default is true.
  # config.required_by_default = true

  # Tell browsers whether to use the native HTML5 validations (novalidate form option).
  # These validations are enabled in SimpleForm's internal config but disabled by default
  # in this configuration, which is recommended due to some quirks from different browsers.
  # To stop SimpleForm from generating the novalidate option, enabling the HTML5 validations,
  # change this configuration to true.
  config.browser_validations = false

  # Collection of methods to detect if a file type was given.
  # config.file_methods = [ :mounted_as, :file?, :public_filename ]

  # Custom mappings for input types. This should be a hash containing a regexp
  # to match as key, and the input type that will be used when the field name
  # matches the regexp as value.
  # config.input_mappings = { /count/ => :integer }

  # Custom wrappers for input types. This should be a hash containing an input
  # type as key and the wrapper that will be used for all inputs with specified type.
  # config.wrapper_mappings = { string: :prepend }

  # Default priority for time_zone inputs.
  # config.time_zone_priority = nil

  # Default priority for country inputs.
  # config.country_priority = nil

  # When false, do not use translations for labels.
  # config.translate_labels = true

  # Automatically discover new inputs in Rails' autoload path.
  # config.inputs_discovery = true

  # Cache SimpleForm inputs discovery
  # config.cache_discovery = !Rails.env.development?

  # Default class for inputs
  config.input_class = 'w-input text-field'
end
