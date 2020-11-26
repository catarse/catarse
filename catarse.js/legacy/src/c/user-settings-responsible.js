import m from 'mithril';
import _ from 'underscore';
import bigCard from './big-card';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'users.edit.settings_tab');

const userSettingsResponsible = {
    view: function({attrs})
    {
        const 
            disableFields = attrs.disableFields,
            fields = attrs.fields(),
            parsedErrors = attrs.parsedErrors,
            applyDocumentMask = attrs.applyDocumentMask,
            applyBirthDateMask = attrs.applyBirthDateMask,
            user = attrs.user;

        return m(bigCard, {
            label: window.I18n.t('legal_title', I18nScope()),
            label_hint: m.trust(window.I18n.t('legal_subtitle', I18nScope())),
            children: [

                m('.divider.u-marginbottom-20'),
                m('.w-row', [
                    m('.w-col.w-col-5.w-sub-col',
                        m('.input.select.required.user_bank_account_bank_id', [
                            m(`select.select.required.w-input.text-field.bank-select.positive${(disableFields ? '.text-field-disabled' : '')}[id='user_bank_account_attributes_bank_id']`, {
                                name: 'user[bank_account_attributes][bank_id]',
                                onchange: m.withAttr('value', fields.account_type),
                                disabled: disableFields
                            }, [
                                m('option[value=\'pf\']', {
                                    selected: fields.account_type() === 'pf'
                                }, window.I18n.t('account_types.pf', I18nScope())),
                                m('option[value=\'pj\']', {
                                    selected: fields.account_type() === 'pj'
                                }, window.I18n.t('account_types.pj', I18nScope())),
                                m('option[value=\'mei\']', {
                                    selected: fields.account_type() === 'mei'
                                }, window.I18n.t('account_types.mei', I18nScope())),
                            ])
                        ])
                    ),
                ]),
                m('.w-row', [
                    m('.w-col.w-col-5.w-sub-col', [
                        m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark[for=\'user_bank_account_attributes_owner_name\']',
                            window.I18n.t(
                                (fields.account_type() == 'pf' ? 'pf_label_name' : 'pj_label_name'),
                                I18nScope()
                            )
                        ),
                        m(`input.string.required.w-input.text-field.positive${(disableFields ? '.text-field-disabled' : '')}[id='user_bank_account_attributes_owner_name'][type='text']`, {
                            value: fields.name(),
                            name: 'user[name]',
                            class: parsedErrors.hasError('name') ? 'error' : false,
                            onchange: m.withAttr('value', fields.name),
                            disabled: disableFields
                        }),
                        parsedErrors.inlineError('name')
                    ]),
                    m('.w-col.w-col-7', [
                        m('.w-row', [
                            m('.w-col.w-col-6.w-col-small-6.w-col-tiny-6.w-sub-col-middle', [
                                m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark[for=\'user_bank_account_attributes_owner_document\']',
                                    window.I18n.t((fields.account_type() == 'pf' ? 'pf_label_document' : 'pj_label_document'), I18nScope())
                                ),
                                m(`input.string.tel.required.w-input.text-field.positive${(disableFields ? '.text-field-disabled' : '')}[data-validate-cpf-cnpj='true'][id='user_bank_account_attributes_owner_document'][type='tel'][validation_text='true']`, {
                                    value: fields.owner_document(),
                                    class: parsedErrors.hasError('owner_document') ? 'error' : false,
                                    disabled: disableFields,
                                    name: 'user[cpf]',
                                    onchange: m.withAttr('value', applyDocumentMask),
                                    onkeyup: m.withAttr('value', applyDocumentMask)
                                }),
                                parsedErrors.inlineError('owner_document')
                            ]),
                            m('.w-col.w-col-6.w-col-small-6.w-col-tiny-6', (fields.account_type() == 'pf' ? [
                                m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark[for=\'user_bank_account_attributes_owner_document\']',
                                    window.I18n.t('label_birth_date', I18nScope())
                                ),
                                m(`input.string.tel.required.w-input.text-field.positive${((disableFields && !_.isEmpty(user.birth_date)) ? '.text-field-disabled' : '')}[data-validate-cpf-cnpj='true'][id='user_bank_account_attributes_owner_document'][type='tel'][validation_text='true']`, {
                                    value: fields.birth_date(),
                                    name: 'user[birth_date]',
                                    class: parsedErrors.hasError('birth_date') ? 'error' : false,
                                    disabled: (disableFields && !_.isEmpty(user.birth_date)),
                                    onchange: m.withAttr('value', applyBirthDateMask),
                                    onkeyup: m.withAttr('value', applyBirthDateMask)
                                }),
                                parsedErrors.inlineError('birth_date')
                            ] : [
                                m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark[for=\'user_bank_account_attributes_owner_document\']',
                                    window.I18n.t('label_state_inscription', I18nScope())
                                ),
                                m('input.string.tel.required.w-input.text-field.positive[data-validate-cpf-cnpj=\'true\'][id=\'user_bank_account_attributes_owner_document\'][type=\'tel\'][validation_text=\'true\']', {
                                    value: fields.state_inscription(),
                                    class: parsedErrors.hasError('state_inscription') ? 'error' : false,
                                    name: 'user[state_inscription]',
                                    onchange: m.withAttr('value', fields.state_inscription)
                                }),
                                parsedErrors.inlineError('state_inscription')
                            ]))
                        ])
                    ])

                ])
            ]
        });
    }
};

export default userSettingsResponsible;
