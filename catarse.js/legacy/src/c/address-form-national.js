import m from 'mithril';
import inlineError from '../c/inline-error';
import countrySelect from '../c/country-select';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'activerecord.attributes.address');

const addressFormNational = {
    view: function ({ attrs }) {
        const disableInternational = attrs.disableInternational;
        const countryName = attrs.countryName;
        const fields = attrs.fields;
        const international = attrs.international;
        const defaultCountryID = attrs.defaultCountryID;
        const defaultForeignCountryID = attrs.defaultForeignCountryID;
        const errors = attrs.errors;
        const applyZipcodeMask = attrs.applyZipcodeMask;
        const lookupZipCode = attrs.lookupZipCode;
        const zipCodeErrorMessage = attrs.zipCodeErrorMessage;
        const countryStates = attrs.countryStates;
        const applyPhoneMask = attrs.applyPhoneMask;

        return m('.w-form', [
            m('div', [
                disableInternational
                    ? null
                    : m(countrySelect, {
                        countryName,
                        fields,
                        international,
                        defaultCountryID,
                        defaultForeignCountryID,
                    }),
                m('div', [
                    m('.w-row', [
                        m('.w-col.w-col-6', [
                            m('.field-label', [
                                m('span.fontweight-semibold', `${window.I18n.t('address_zip_code', I18nScope())} *`),
                                m(
                                    'a.fontsize-smallest.alt-link.u-right[href=\'http://www.buscacep.correios.com.br/sistemas/buscacep/\'][target=\'_blank\']',
                                    window.I18n.t('zipcode_unknown', I18nScope())
                                ),
                            ]),
                            m('input.positive.text-field.w-input[placeholder=\'Digite apenas números\'][required=\'required\'][type=\'text\']', {
                                class: errors.addressZipCode() ? 'error' : '',
                                value: fields.addressZipCode(),
                                onkeyup: (event) => applyZipcodeMask(event.target.value),
                                oninput: e => {
                                    lookupZipCode(e.target.value);
                                },
                            }),
                            errors.addressZipCode()
                                ? m(inlineError, {
                                    message: zipCodeErrorMessage() ? zipCodeErrorMessage() : 'Informe um CEP válido.',
                                })
                                : '',
                        ]),
                        m('.w-col.w-col-6'),
                    ]),
                    m('.w-row', [
                        m('.field-label.fontweight-semibold', `${window.I18n.t('address_street', I18nScope())} *`),
                        m('input.positive.text-field.w-input[maxlength=\'50\'][required=\'required\'][type=\'text\']', {
                            class: errors.addressStreet() ? 'error' : '',
                            value: fields.addressStreet(),
                            oninput: m.withAttr('value', fields.addressStreet),
                        }),
                        errors.addressStreet()
                            ? m(inlineError, {
                                message: 'Informe um endereço com no máximo 50 caracteres. Se for necessário, use abreviações..',
                            })
                            : '',
                    ]),
                    m('.w-row', [
                        m('.w-sub-col.w-col.w-col-4', [
                            m('.field-label.fontweight-semibold', `${window.I18n.t('address_number', I18nScope())} *`),
                            m('input.positive.text-field.w-input[required=\'required\'][type=\'text\']', {
                                class: errors.addressNumber() ? 'error' : '',
                                value: fields.addressNumber(),
                                oninput: m.withAttr('value', fields.addressNumber),
                            }),
                            errors.addressNumber()
                                ? m(inlineError, {
                                    message: 'Informe um número.',
                                })
                                : '',
                        ]),
                        m('.w-sub-col.w-col.w-col-4', [
                            m('.field-label.fontweight-semibold', window.I18n.t('address_complement', I18nScope())),
                            m('input.positive.text-field.w-input[maxlength="30"][required="required"][type="text"]', {
                                value: fields.addressComplement(),
                                oninput: m.withAttr('value', fields.addressComplement),
                            }),
                        ]),
                        m('.w-col.w-col-4', [
                            m('.field-label.fontweight-semibold', `${window.I18n.t('address_neighbourhood', I18nScope())} *`),
                            m('input.positive.text-field.w-input[maxlength="30"][required="required"][type="text"]', {
                                class: errors.addressNeighbourhood() ? 'error' : '',
                                value: fields.addressNeighbourhood(),
                                oninput: m.withAttr('value', fields.addressNeighbourhood),
                            }),
                            errors.addressNeighbourhood()
                                ? m(inlineError, {
                                    message: 'Informe um bairro.',
                                })
                                : '',
                        ]),
                    ]),
                    m('.w-row', [
                        m('.w-sub-col.w-col.w-col-6', [
                            m('.field-label.fontweight-semibold', `${window.I18n.t('address_city', I18nScope())} *`),
                            m('input.positive.text-field.w-input[required="required"][type="text"]', {
                                class: errors.addressCity() ? 'error' : '',
                                value: fields.addressCity(),
                                oninput: m.withAttr('value', fields.addressCity),
                            }),
                            errors.addressCity()
                                ? m(inlineError, {
                                    message: 'Informe uma cidade.',
                                })
                                : '',
                        ]),
                        m('.w-sub-col.w-col.w-col-2', [
                            m('.field-label.fontweight-semibold', `${window.I18n.t('address_state', I18nScope())} *`),
                            m(
                                'select#address-state.positive.text-field.w-select',
                                {
                                    class: errors.stateID() ? 'error' : '',
                                    oninput: (event) => {
                                        const stateSelectedID = Number(event.target.value);
                                        fields.stateID(stateSelectedID);

                                        if (!_.isEmpty(countryStates())) {
                                            const countryState = _.first(_.filter(countryStates(), countryState => {
                                                return stateSelectedID === countryState.id;
                                            }));

                                            if (countryState) {
                                                fields.addressState(countryState.acronym);
                                            } else {
                                                fields.addressState('');
                                            }
                                        }
                                    },
                                },
                                [
                                    m('option', { value: '' }),
                                    !_.isEmpty(countryStates())
                                        ? _.map(countryStates(), countryState =>
                                            m(
                                                'option',
                                                {
                                                    value: countryState.id,
                                                    selected: fields && countryState.id === fields.stateID(),
                                                },
                                                countryState.acronym
                                            )
                                        )
                                        : '',
                                ]
                            ),
                            errors.stateID()
                                ? m(inlineError, {
                                    message: 'Informe um estado.',
                                })
                                : '',
                        ]),
                        m('.w-col.w-col-4', [
                            m('.field-label.fontweight-semibold', `${window.I18n.t('phone_number', I18nScope())} *`),
                            m('input#phone.positive.text-field.w-input[placeholder="Digite apenas números"][required="required"][type="text"]', {
                                class: errors.phoneNumber() ? 'error' : '',
                                value: fields.phoneNumber(),
                                onkeyup: (event) => applyPhoneMask(event.target.value)
                            }),
                            errors.phoneNumber()
                                ? m(inlineError, {
                                    message: 'Informe um telefone válido.',
                                })
                                : '',
                        ]),
                    ]),
                ]),
            ]),
        ]);
    },
};

export default addressFormNational;
