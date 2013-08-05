# You can opt-in to Formtastic's use of the HTML5 `required` attribute on `<input>`, `<select>` 
# and `<textarea>` tags by setting this to false (defaults to true).
Formtastic::FormBuilder.use_required_attribute = true

# You can opt-in to new HTML5 browser validations (for things like email and url inputs) by setting
# this to false. Doing so will add a `novalidate` attribute to the `<form>` tag.
# See http://diveintohtml5.org/forms.html#validation for more info.
Formtastic::FormBuilder.perform_browser_validations = true
Formtastic::FormBuilder.i18n_lookups_by_default = true
