import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';

const userBankForm = {
    oninit: function (vnode) {
        const parsedErrors = vnode.attrs.parsedErrors;
        const userBankAccount = vnode.attrs.userBankAccount;
        const banks = vnode.attrs.banks;
        const showOtherBanks = h.toggleProp(false, true);
        const showOtherBanksInput = prop(false);
        const popularBanks = [{
            id: '51',
            code: '001',
            name: 'Banco do Brasil S.A.'
        }, {
            id: '131',
            code: '341',
            name: 'Itaú Unibanco S.A.'
        }, {
            id: '122',
            code: '104',
            name: 'Caixa Econômica Federal'
        }, {
            id: '104',
            code: '033',
            name: 'Banco Santander  (Brasil)  S.A.'
        }, {
            id: '127',
            code: '399',
            name: 'HSBC Bank Brasil S.A. - Banco Múltiplo'
        }, {
            id: '23',
            code: '237',
            name: 'Banco Bradesco S.A.'
        }];

        vnode.state = {
            bankInput: vnode.attrs.bankInput,
            bankCode: vnode.attrs.bankCode,
            banks,
            showOtherBanksInput,
            showOtherBanks,
            popularBanks,
            userBankAccount,
            parsedErrors
        };
    },
    view: function ({ state, attrs }) {
        const fields = attrs.fields;
        const userBankAccount = state.userBankAccount();
        
        return m('div', [
            m('.w-row', [
                m(`.w-col.w-col-5.w-sub-col${state.showOtherBanksInput() ? '.w-hidden' : ''}[id='bank_select']`,
                    m('.input.select.required.user_bank_account_bank_id', [
                        m('label.field-label.fontsize-smaller',
                            'Banco'
                        ),
                        m('select.select.required.w-input.text-field.bank-select.positive[id=\'user_bank_account_attributes_bank_id\']', {
                            name: 'user[bank_account_attributes][bank_id]',
                            class: state.parsedErrors.hasError('bank_id') ? 'error' : false,
                            onchange: (e) => {
                                m.withAttr('value', state.bankCode)(e);
                                state.showOtherBanksInput(state.bankCode() === '0');
                            }
                        }, [
                            m('option[value=\'\']', {
                                selected: fields.bank_id() === ''
                            }),
                            (_.map(state.popularBanks, bank => (fields.bank_id() !== bank.id ? m(`option[value='${bank.id}']`, {
                                selected: fields.bank_id() === bank.id
                            }, `${bank.code} . ${bank.name}`) : ''))),
                            (fields.bank_id() === '' || _.find(state.popularBanks, bank => bank.id === fields.bank_id())
                                ? ''
                                : m(`option[value='${fields.bank_id()}']`, {
                                    selected: true,
                                }, `${userBankAccount.bank_code} . ${userBankAccount.bank_name}`)
                            ),
                            m('option[value=\'0\']',
                                'Outro'
                            )
                        ]),
                        m('.fontsize-smaller.text-error.u-marginbottom-20.fa.fa-exclamation-triangle.w-hidden[data-error-for=\'user_bank_account_attributes_bank_id\']',
                            ' Selecione um banco'
                        ),
                        state.parsedErrors.inlineError('bank_id')
                    ])
                ),
                (state.showOtherBanksInput()
                    ? m('.w-col.w-col-5.w-sub-col',
                        m('.w-row.u-marginbottom-20[id=\'bank_search\']',
                            m('.w-col.w-col-12', [
                                m('.input.string.optional.user_bank_account_input_bank_number', [
                                    m('label.field-label.fontsize-smaller',
                                        'Número do banco (3 números)'
                                    ),
                                    m('input.string.optional.w-input.text-field.bank_account_input_bank_number[id=\'user_bank_account_attributes_input_bank_number\'][maxlength=\'3\'][size=\'3\'][type=\'text\']', {
                                        name: 'user[bank_account_attributes][input_bank_number]',
                                        value: state.bankInput(),
                                        onchange: m.withAttr('value', state.bankInput)
                                    }),
                                    m('.fontsize-smaller.text-error.u-marginbottom-20.fa.fa-exclamation-triangle.w-hidden[data-error-for=\'user_bank_account_attributes_input_bank_number\']',

                                        ' Número do banco inválido'
                                    )
                                ]),
                                m('a.w-hidden-small.w-hidden-tiny.alt-link.fontsize-smaller[href=\'javascript:void(0);\'][id=\'show_bank_list\']', {
                                    onclick: state.showOtherBanks.toggle
                                }, [
                                    'Busca por nome  ',
                                    m.trust('&nbsp;'),
                                    m.trust('&gt;')
                                ]),
                                m('a.w-hidden-main.w-hidden-medium.alt-link.fontsize-smaller[href=\'javascript:void(0);\'][id=\'show_bank_list\']', {
                                    onclick: state.showOtherBanks.toggle
                                }, [
                                    'Busca por nome  ',
                                    m.trust('&nbsp;'),
                                    m.trust('&gt;')
                                ])
                            ])
                        )
                    ) : ''),
                (state.showOtherBanks()
                    ? m('.w-row[id=\'bank_search_list\']',
                        m('.w-col.w-col-12',
                            m('.select-bank-list[data-ix=\'height-0-on-load\']', {
                                style: {
                                    height: '395px'
                                }
                            },
                            m('.card.card-terciary', [
                                m('.fontsize-small.fontweight-semibold.u-marginbottom-10.u-text-center',
                                    'Selecione o seu banco abaixo'
                                ),
                                m('.fontsize-smaller', [
                                    m('.w-row.card.card-secondary.fontweight-semibold', [
                                        m('.w-col.w-col-3.w-col-small-3.w-col-tiny-3',
                                            m('div',
                                                'Número'
                                            )
                                        ),
                                        m('.w-col.w-col-9.w-col-small-9.w-col-tiny-9',
                                            m('div',
                                                'Nome'
                                            )
                                        )
                                    ]),
                                    (!_.isEmpty(state.banks())
                                        ? _.map(state.banks(), bank => m('.w-row.card.fontsize-smallest', [
                                            m('.w-col.w-col-3.w-col-small-3.w-col-tiny-3',
                                                m(`a.link-hidden.bank-resource-link[data-code='${bank.code}'][data-id='${bank.id}'][href='javascript:void(0)']`, {
                                                    onclick: () => {
                                                        state.bankInput(bank.code);
                                                        state.showOtherBanks.toggle();
                                                    }
                                                }, bank.code)
                                            ),
                                            m('.w-col.w-col-9.w-col-small-9.w-col-tiny-9',
                                                m(`a.link-hidden.bank-resource-link[data-code='${bank.code}'][data-id='${bank.id}'][href='javascript:void(0)']`, {
                                                    onclick: () => {
                                                        state.bankInput(bank.code);
                                                        state.showOtherBanks.toggle();
                                                    }
                                                },
                                                `${bank.code} . ${bank.name}`
                                                )
                                            )
                                        ])) : '')
                                ])
                            ])
                            )
                        )
                    ) : ''),
                m('.w-col.w-col-7',
                    m('.w-row', [
                        m('.w-col.w-col-7.w-col-small-7.w-col-tiny-7.w-sub-col-middle', [
                            m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark.fontsize-smaller[for=\'user_bank_account_attributes_agency\']',
                                'Agência'
                            ),
                            m('input.string.required.w-input.text-field.positive[id=\'user_bank_account_attributes_agency\'][type=\'text\']', {
                                value: fields.agency(),
                                class: state.parsedErrors.hasError('agency') ? 'error' : false,
                                name: 'user[bank_account_attributes][agency]',
                                onchange: m.withAttr('value', fields.agency)
                            }),
                            state.parsedErrors.inlineError('agency')
                        ]),
                        m('.w-col.w-col-5.w-col-small-5.w-col-tiny-5', [
                            m('label.text.optional.field-label.field-label.fontweight-semibold.force-text-dark.fontsize-smaller[for=\'user_bank_account_attributes_agency_digit\']',
                                'Dígito agência'
                            ),
                            m('input.string.optional.w-input.text-field.positive[id=\'user_bank_account_attributes_agency_digit\'][type=\'text\']', {
                                value: fields.agency_digit(),
                                class: state.parsedErrors.hasError('agency_digit') ? 'error' : false,
                                name: 'user[bank_account_attributes][agency_digit]',
                                onchange: m.withAttr('value', fields.agency_digit)
                            }),
                            state.parsedErrors.inlineError('agency_digit')
                        ])
                    ])
                )
            ]),
            m('.w-row', [
                m('.w-col.w-col-5.w-sub-col', [
                    m('label.field-label.fontweight-semibold.fontsize-smaller',
                        'Tipo de conta'
                    ),
                    m('.input.select.required.user_bank_account_account_type', [
                        m('select.select.required.w-input.text-field.bank-select.positive[id=\'user_bank_account_attributes_account_type\']', {
                            name: 'user[bank_account_attributes][account_type]',
                            class: state.parsedErrors.hasError('account_type') ? 'error' : false,
                            onchange: m.withAttr('value', fields.bank_account_type)
                        }, [
                            m('option[value=\'conta_corrente\']', {
                                selected: fields.bank_account_type() === 'conta_corrente'
                            }, 'Conta corrente'),
                            m('option[value=\'conta_poupanca\']', {
                                Selected: fields.bank_account_type() === 'conta_poupanca'
                            }, 'Conta poupança'),
                            m('option[value=\'conta_corrente_conjunta\']', {
                                selected: fields.bank_account_type() === 'conta_corrente_conjunta'
                            }, 'Conta corrente conjunta'),
                            m('option[value=\'conta_poupanca_conjunta\']', {
                                selected: fields.bank_account_type() === 'conta_poupanca_conjunta'
                            }, 'Conta poupança conjunta')
                        ]),
                        state.parsedErrors.inlineError('account_type')
                    ])
                ]),
                m('.w-col.w-col-7',
                    m('.w-row', [
                        m('.w-col.w-col-7.w-col-small-7.w-col-tiny-7.w-sub-col-middle', [
                            m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark.fontsize-smaller[for=\'user_bank_account_attributes_account\']',
                                'No. da conta'
                            ),
                            m('input.string.required.w-input.text-field.positive[id=\'user_bank_account_attributes_account\'][type=\'text\']', {
                                value: fields.account(),
                                class: state.parsedErrors.hasError('account') ? 'error' : false,
                                onchange: m.withAttr('value', fields.account),
                                name: 'user[bank_account_attributes][account]'
                            }),
                            state.parsedErrors.inlineError('account')
                        ]),
                        m('.w-col.w-col-5.w-col-small-5.w-col-tiny-5', [
                            m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark.fontsize-smaller[for=\'user_bank_account_attributes_account_digit\']',
                                'Dígito conta'
                            ),
                            m('input.string.required.w-input.text-field.positive[id=\'user_bank_account_attributes_account_digit\'][type=\'text\']', {
                                value: fields.account_digit(),
                                class: state.parsedErrors.hasError('account_digit') ? 'error' : false,
                                onchange: m.withAttr('value', fields.account_digit),
                                name: 'user[bank_account_attributes][account_digit]'
                            }),
                            state.parsedErrors.inlineError('account_digit')
                        ])
                    ])
                )
            ]),
            (userBankAccount.bank_account_id
                ? m('input[id=\'user_bank_account_attributes_id\'][type=\'hidden\']', {
                    name: 'user[bank_account_attributes][id]',
                    value: fields.bank_account_id()
                }) : '')
        ]);
    }
};

export default userBankForm;
