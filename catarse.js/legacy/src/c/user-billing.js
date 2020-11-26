import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import models from '../models';
import h from '../h';
import userVM from '../vms/user-vm';
import popNotification from './pop-notification';

const userBilling = {
    oninit: function(vnode) {
        models.bank.pageSize(false);
        const user = vnode.attrs.user,
            bankAccount = prop({}),
            fields = {
                owner_name: prop(''),
                agency: prop(''),
                bank_id: prop(''),
                agency_digit: prop(''),
                account: prop(''),
                account_digit: prop(''),
                owner_document: prop(''),
                bank_account_id: prop('')
            },
            userId = vnode.attrs.userId,
            error = prop(''),
            showError = prop(false),
            loader = prop(true),
            bankInput = prop(''),
            bankCode = prop('-1'),
            banks = prop(),
            handleError = () => {
                error(true);
                loader(false);
                m.redraw();
            },
            banksLoader = catarse.loader(models.bank.getPageOptions()),
            showSuccess = prop(false),
            showOtherBanks = h.toggleProp(false, true),
            showOtherBanksInput = prop(false),
            setCsrfToken = (xhr) => {
                if (h.authenticityToken()) {
                    xhr.setRequestHeader('X-CSRF-Token', h.authenticityToken());
                }
            },
            confirmDelete = (cardId) => {
                const r = confirm('você tem certeza?');
                if (r) {
                    return m.request({
                        method: 'DELETE',
                        url: `/users/${user.id}/credit_cards/${cardId}`,
                        config: setCsrfToken
                    }).then(() => {
                        location.reload();
                    }).catch(handleError);
                }
                return false;
            },
            popularBanks = [{
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
            }],
            // Little trick to reproduce Rails+SimpleForm behavior
            // We create a hidden form with the correct input values set
            // Then we submit it when the remove card button is clicked
            // The card id is set on the go, with the help of a closure.
            updateUserData = (user_id) => {
                const userData = {
                    owner_name: fields.owner_name(),
                    owner_document: fields.owner_document(),
                    bank_id: bankCode(),
                    input_bank_number: bankInput(),
                    agency_digit: fields.agency_digit(),
                    agency: fields.agency(),
                    account: fields.account(),
                    account_digit: fields.account_digit()
                };
                if ((fields.bank_account_id())) {
                    userData.id = fields.bank_account_id().toString();
                }

                return m.request({
                    method: 'PUT',
                    url: `/users/${user_id}.json`,
                    data: {
                        user: { bank_account_attributes: userData }
                    },
                    config: setCsrfToken
                }).then(() => {
                    showSuccess(true);
                    m.redraw();
                }).catch((err) => {
                    if (_.isArray(err.errors)) {
                        error(err.errors.join('<br>'));
                    } else {
                        error('Erro ao atualizar informações.');
                    }

                    showError(true);
                    m.redraw();
                });
            },
            onSubmit = () => {
                updateUserData(userId);

                return false;
            };

        userVM.getUserBankAccount(userId).then((data) => {
            if (!_.isEmpty(_.first(data))) {
                bankAccount(_.first(data));
                fields.owner_document(bankAccount().owner_document);
                fields.owner_name(bankAccount().owner_name);
                fields.bank_account_id(bankAccount().bank_account_id);
                fields.account(bankAccount().account);
                fields.account_digit(bankAccount().account_digit);
                fields.agency(bankAccount().agency);
                fields.agency_digit(bankAccount().agency_digit);
                fields.bank_id(bankAccount().bank_id);
                bankCode(bankAccount().bank_id);
            }
        }).catch(handleError);

        banksLoader.load().then(banks).catch(handleError);

        vnode.state = {
            bankAccount,
            confirmDelete,
            bankInput,
            banks,
            showError,
            showOtherBanks,
            fields,
            showOtherBanksInput,
            loader,
            bankCode,
            onSubmit,
            showSuccess,
            popularBanks,
            user,
            error
        };
    },
    view: function({state, attrs}) {
        let user = attrs.user,
            fields = state.fields,
            bankAccount = state.bankAccount();

        return m('[id=\'billing-tab\']', [
            (state.showSuccess() ? m(popNotification, {
                message: 'As suas informações foram atualizadas'
            }) : ''),
            (state.showError() ? m(popNotification, {
                message: m.trust(state.error()),
                error: true
            }) : ''),
            m('.w-row',
                m('.w-col.w-col-10.w-col-push-1', [
                    m('form.simple_form.refund_bank_account_form', { onsubmit: state.onSubmit }, [
                        m('input[id=\'anchor\'][name=\'anchor\'][type=\'hidden\'][value=\'billing\']'),
                        m('.w-form.card.card-terciary', [
                            m('.fontsize-base.fontweight-semibold',
                                'Dados bancários'
                            ),
                            m('.fontsize-small.u-marginbottom-20', [
                                'Caso algum projeto que você tenha apoiado ',
                                m('b',
                                    'com Boleto Bancário'
                                ),
                                ' não seja bem-sucedido, nós efetuaremos o reembolso de seu pagamento ',
                                m('b',
                                    'automaticamente'
                                ),
                                ' na conta indicada abaixo.'
                            ]),
                            m('.divider.u-marginbottom-20'),
                            m('.w-row', [
                                m('.w-col.w-col-6.w-sub-col', [
                                    m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark[for=\'user_bank_account_attributes_owner_name\']',
                                        'Nome do titular'
                                    ),
                                    m('input.string.required.w-input.text-field.positive[id=\'user_bank_account_attributes_owner_name\'][type=\'text\']', {
                                        value: fields.owner_name(),
                                        name: 'user[bank_account_attributes][owner_name]',
                                        onchange: m.withAttr('value', fields.owner_name)
                                    })
                                ]),
                                m('.w-col.w-col-6', [
                                    m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark[for=\'user_bank_account_attributes_owner_document\']',
                                        'CPF / CNPJ do titular'
                                    ),
                                    m('input.string.tel.required.w-input.text-field.positive[data-validate-cpf-cnpj=\'true\'][id=\'user_bank_account_attributes_owner_document\'][type=\'tel\'][validation_text=\'true\']', {
                                        value: fields.owner_document(),
                                        name: 'user[bank_account_attributes][owner_document]',
                                        onchange: m.withAttr('value', fields.owner_document)
                                    })
                                ])
                            ]),
                            m('.w-row', [
                                m(`.w-col.w-col-6.w-sub-col${state.showOtherBanksInput() ? '.w-hidden' : ''}[id='bank_select']`,
                                    m('.input.select.required.user_bank_account_bank_id', [
                                        m('label.field-label',
                                            'Banco'
                                        ),
                                        m('select.select.required.w-input.text-field.bank-select.positive[id=\'user_bank_account_attributes_bank_id\']', {
                                            name: 'user[bank_account_attributes][bank_id]',
                                            onchange: (e) => {
                                                m.withAttr('value', state.bankCode)(e);
                                                state.showOtherBanksInput(state.bankCode() == '0');
                                            }
                                        }, [
                                            m('option[value=\'\']', { selected: fields.bank_id() === '' }),
                                            (_.map(state.popularBanks, bank => (fields.bank_id() != bank.id ? m(`option[value='${bank.id}']`, {
                                                selected: fields.bank_id() == bank.id
                                            },
                                                    `${bank.code} . ${bank.name}`) : ''))),
                                            (fields.bank_id() === '' || _.find(state.popularBanks, bank => bank.id === fields.bank_id()) ? '' :
                                                m(`option[value='${fields.bank_id()}']`, {
                                                    selected: true
                                                },
                                                    `${bankAccount.bank_code} . ${bankAccount.bank_name}`
                                                )
                                            ),
                                            m('option[value=\'0\']',
                                                'Outro'
                                            )
                                        ]),
                                        m('.fontsize-smaller.text-error.u-marginbottom-20.fa.fa-exclamation-triangle.w-hidden[data-error-for=\'user_bank_account_attributes_bank_id\']',
                                            ' Selecione um banco'
                                        )
                                    ])
                                ),
                                (state.showOtherBanksInput() ?
                                    m('.w-col.w-col-6.w-sub-col',
                                        m('.w-row.u-marginbottom-20[id=\'bank_search\']',
                                            m('.w-col.w-col-12', [
                                                m('.input.string.optional.user_bank_account_input_bank_number', [
                                                    m('label.field-label',
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
                                (state.showOtherBanks() ?
                                    m('.w-row[id=\'bank_search_list\']',
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
                                                        (!_.isEmpty(state.banks()) ?
                                                            _.map(state.banks(), bank => m('.w-row.card.fontsize-smallest', [
                                                                m('.w-col.w-col-3.w-col-small-3.w-col-tiny-3',
                                                                        m(`a.link-hidden.bank-resource-link[data-code='${bank.code}'][data-id='${bank.id}'][href='javascript:void(0)']`, {
                                                                            onclick: () => {
                                                                                state.bankInput(bank.code);
                                                                                state.showOtherBanks.toggle();
                                                                            }
                                                                        },
                                                                            bank.code
                                                                        )
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
                                m('.w-col.w-col-6',
                                    m('.w-row', [
                                        m('.w-col.w-col-6.w-col-small-6.w-col-tiny-6.w-sub-col-middle', [
                                            m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark[for=\'user_bank_account_attributes_agency\']',
                                                'Agência'
                                            ),
                                            m('input.string.required.w-input.text-field.positive[id=\'user_bank_account_attributes_agency\'][type=\'text\']', {
                                                value: fields.agency(),
                                                name: 'user[bank_account_attributes][agency]',
                                                onchange: m.withAttr('value', fields.agency)
                                            })
                                        ]),
                                        m('.w-col.w-col-6.w-col-small-6.w-col-tiny-6', [
                                            m('label.text.optional.field-label.field-label.fontweight-semibold.force-text-dark[for=\'user_bank_account_attributes_agency_digit\']',
                                                'Dígito agência'
                                            ),
                                            m('input.string.optional.w-input.text-field.positive[id=\'user_bank_account_attributes_agency_digit\'][type=\'text\']', {
                                                value: fields.agency_digit(),
                                                name: 'user[bank_account_attributes][agency_digit]',
                                                onchange: m.withAttr('value', fields.agency_digit)
                                            })
                                        ])
                                    ])
                                )
                            ]),
                            m('.w-row', [
                                m('.w-col.w-col-6.w-sub-col', [
                                    m('label.field-label.fontweight-semibold',
                                        'Tipo de conta'
                                    ),
                                    m('p.fontsize-smaller.u-marginbottom-20',
                                        'Só aceitamos conta corrente'
                                    )
                                ]),
                                m('.w-col.w-col-6',
                                    m('.w-row', [
                                        m('.w-col.w-col-6.w-col-small-6.w-col-tiny-6.w-sub-col-middle', [
                                            m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark[for=\'user_bank_account_attributes_account\']',
                                                'No. da conta'
                                            ),
                                            m('input.string.required.w-input.text-field.positive[id=\'user_bank_account_attributes_account\'][type=\'text\']', {
                                                value: fields.account(),
                                                onchange: m.withAttr('value', fields.account),
                                                name: 'user[bank_account_attributes][account]'
                                            })
                                        ]),
                                        m('.w-col.w-col-6.w-col-small-6.w-col-tiny-6', [
                                            m('label.text.required.field-label.field-label.fontweight-semibold.force-text-dark[for=\'user_bank_account_attributes_account_digit\']',
                                                'Dígito conta'
                                            ),
                                            m('input.string.required.w-input.text-field.positive[id=\'user_bank_account_attributes_account_digit\'][type=\'text\']', {
                                                value: fields.account_digit(),
                                                onchange: m.withAttr('value', fields.account_digit),
                                                name: 'user[bank_account_attributes][account_digit]'
                                            })
                                        ])
                                    ])
                                )
                            ]),
                            (bankAccount.bank_account_id ?
                            m('input[id=\'user_bank_account_attributes_id\'][type=\'hidden\']', {
                                name: 'user[bank_account_attributes][id]',
                                value: fields.bank_account_id()
                            }) : '')
                        ]),
                        m('.u-margintop-30',
                            m('.w-container',
                                m('.w-row',
                                    m('.w-col.w-col-4.w-col-push-4',
                                        m('input.btn.btn-large[name=\'commit\'][type=\'submit\'][value=\'Salvar\']')
                                    )
                                )
                            )
                        )
                    ])
                ])
            )
        ]);
    }
};

export default userBilling;

