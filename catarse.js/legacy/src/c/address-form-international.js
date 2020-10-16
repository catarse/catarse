import m from 'mithril';
import inlineError from '../c/inline-error';
import countrySelect from '../c/country-select';

const addressFormInternational = {
    view: function({ attrs }) {
        const fields = attrs.fields;
        const disableInternational = attrs.disableInternational;
        const addVM = attrs.addVM;
        const countryName = attrs.countryName;
        const international = attrs.international;
        const defaultCountryID = attrs.defaultCountryID;
        const defaultForeignCountryID = attrs.defaultForeignCountryID;
        const errors = attrs.errors;
    
        return m('form', [
            disableInternational ? '' : m(countrySelect, {
                countryName,
                fields,
                addVM,
                international,
                defaultCountryID,
                defaultForeignCountryID
            }),
            m('div', [
                m('.w-row',
                    m('.w-col.w-col-12', [
                        m('.field-label.fontweight-semibold',
                            'Address *'
                        ),
                        m('input.positive.text-field.w-input[required="required"][type="text"]', {
                            class: errors.addressStreet() ? 'error' : '',
                            value: fields.addressStreet(),
                            oninput: m.withAttr('value', fields.addressStreet)
                        }),
                        errors.addressStreet() ? m(inlineError, {
                            message: 'Please fill in an address.'
                        }) : ''
                    ])),
                m('div',
                    m('.w-row', [
                        m('.w-sub-col.w-col.w-col-4', [
                            m('.field-label.fontweight-semibold',
                                'Zip Code *'
                            ),
                            m('input.positive.text-field.w-input[required=\'required\'][type=\'text\']', {
                                class: errors.addressZipCode() ? 'error' : '',
                                value: fields.addressZipCode(),
                                oninput: m.withAttr('value', fields.addressZipCode)
                            }),
                            errors.addressZipCode() ? m(inlineError, {
                                message: 'ZipCode is required'
                            }) : '',
                        ]),
                        m('.w-sub-col.w-col.w-col-4', [
                            m('.field-label.fontweight-semibold',
                                'City *'
                            ),
                            m('input.positive.text-field.w-input[required=\'required\'][type=\'text\']', {
                                class: errors.addressCity() ? 'error' : '',
                                value: fields.addressCity(),
                                oninput: m.withAttr('value', fields.addressCity)
                            }),
                            errors.addressCity() ? m(inlineError, {
                                message: 'City is required'
                            }) : ''
                        ]),
                        m('.w-col.w-col-4', [
                            m('.field-label.fontweight-semibold',
                                'State *'
                            ),
                            m('input#address-state.positive.text-field.w-input[required=\'required\'][type=\'text\']', {
                                class: errors.addressState() ? 'error' : '',
                                value: fields.addressState(),
                                oninput: m.withAttr('value', fields.addressState)
                            }),
                            errors.addressState() ? m(inlineError, {
                                message: 'State is required'
                            }) : ''
                        ])
                    ])
                )
            ])
        ]);
    }
};

export default addressFormInternational;