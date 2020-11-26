import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';
import models from '../models';
import { catarse } from '../api';
import _ from 'underscore';
import contributionListVM from '../vms/contribution-list-vm';
import contributionFilterVM from '../vms/contribution-filter-vm';
import adminList from '../c/admin-list';
import adminFilter from '../c/admin-filter';
import adminContributionItem from '../c/admin-contribution-item';
import adminContributionDetail from '../c/admin-contribution-detail';
import filterMain from '../c/filter-main';
import filterDropdown from '../c/filter-dropdown';
import filterNumberRange from '../c/filter-number-range';
import filterDateRange from '../c/filter-date-range';
import modalBox from '../c/modal-box';

const adminContributions = {
    oninit: function(vnode) {
        let listVM = contributionListVM,
            filterVM = contributionFilterVM,
            error = prop(''),
            filterBuilder = [{ // full_text_index
                component: filterMain,
                data: {
                    vm: filterVM.full_text_index,
                    placeholder: 'Busque por projeto, email, Ids do usuário e do apoio...'
                }
            }, { // delivery_status
                component: filterDropdown,
                data: {
                    label: 'Status da entrega',
                    name: 'delivery_status',
                    vm: filterVM.delivery_status,
                    options: [{
                        value: '',
                        option: 'Qualquer um'
                    }, {
                        value: 'delivered',
                        option: 'delivered'
                    }, {
                        value: 'undelivered',
                        option: 'undelivered'
                    }, {
                        value: 'error',
                        option: 'error'
                    }, {
                        value: 'received',
                        option: 'received'
                    }]
                }
            }, { // state
                component: filterDropdown,
                data: {
                    label: 'Com o estado',
                    name: 'state',
                    vm: filterVM.state,
                    options: [{
                        value: '',
                        option: 'Qualquer um'
                    }, {
                        value: 'paid',
                        option: 'paid'
                    }, {
                        value: 'refused',
                        option: 'refused'
                    }, {
                        value: 'pending',
                        option: 'pending'
                    }, {
                        value: 'pending_refund',
                        option: 'pending_refund'
                    }, {
                        value: 'refunded',
                        option: 'refunded'
                    }, {
                        value: 'chargeback',
                        option: 'chargeback'
                    }, {
                        value: 'deleted',
                        option: 'deleted'
                    }]
                }
            }, { // gateway
                component: filterDropdown,
                data: {
                    label: 'gateway',
                    name: 'gateway',
                    vm: filterVM.gateway,
                    options: [{
                        value: '',
                        option: 'Qualquer um'
                    }, {
                        value: 'Pagarme',
                        option: 'Pagarme'
                    }, {
                        value: 'MoIP',
                        option: 'MoIP'
                    }, {
                        value: 'PayPal',
                        option: 'PayPal'
                    }, {
                        value: 'Credits',
                        option: 'Créditos'
                    }]
                }
            }, { // value
                component: filterNumberRange,
                data: {
                    label: 'Valores entre',
                    first: filterVM.value.gte,
                    last: filterVM.value.lte
                }
            }, { // created_at
                component: filterDateRange,
                data: {
                    label: 'Período do apoio',
                    first: filterVM.created_at.gte,
                    last: filterVM.created_at.lte
                }
            }],
            submit = () => {
                error(false);
                listVM.firstPage(filterVM.parameters()).then(_ => m.redraw(), (serverError) => {
                    error(serverError.message);
                    m.redraw();
                });
                return false;
            },
            displayChargebackForm = h.toggleProp(false, true),
            chargebackIds = prop(),
            generateIdsToData = () => {
                if (chargebackIds() == undefined) {
                    return null;
                }

                return chargebackIds().split(',').map(str => str.trim());
            },
            processChargebacksLoader = h.toggleProp(false, true),
            displayChargebackConfirmationModal = h.toggleProp(false, true),
            searchChargebackLoader = h.toggleProp(false, true),
            toChargebackListVM = models.contributionDetail,
            toChargebackCollection = prop(),
            chargebackConfirmationModalContentWrapper = (customAttrs) => {
                const wrapper = {
                    view: function({state, attrs}) {
                        return m('', [
                            m('.modal-dialog-header', [
                                m('.fontsize-large.u-text-center', attrs.modalTitle)
                            ]),
                            m('.modal-dialog-content', [
                                m('.w-row.fontweight-semibold', [
                                    m('.w-col.w-col-3', 'ID do gateway'),
                                    m('.w-col.w-col-4', 'Nome do apoiador'),
                                    m('.w-col.w-col-2', 'Valor'),
                                    m('.w-col.w-col-3', 'Projeto'),
                                ]),
                                _.map(toChargebackCollection(), (item, index) => m('.divider.fontsize-smallest.lineheight-looser', [
                                    m('.w-row', [
                                        m('.w-col.w-col-3', [
                                            m('span', item.gateway_id)
                                        ]),
                                        m('.w-col.w-col-4', [
                                            m('span', item.user_name)
                                        ]),
                                        m('.w-col.w-col-2', [
                                            m('span', `${h.formatNumber(item.value, 2, 3)}`)
                                        ]),
                                        m('.w-col.w-col-3', [
                                            m('span', item.project_name)
                                        ]),
                                    ])
                                ])),
                                m('.w-row.fontweight-semibold.divider', [
                                    m('.w-col.w-col-6', 'Total'),
                                    m('.w-col.w-col-3', `R$ ${h.formatNumber(_.reduce(toChargebackCollection(), (t, i) => t + i.value, 0), 2, 3)}`)
                                ]),
                                m('.w-row.u-margintop-40', [
                                    m('.w-col.w-col-1'),
                                    m('.w-col.w-col-5',
                                        m('a.btn.btn-medium.w-button', {
                                            onclick: attrs.onClickCallback
                                        }, attrs.ctaText)
                                    ),
                                    m('.w-col.w-col-5',
                                        m('a.btn.btn-medium.btn-terciary.w-button', {
                                            onclick: attrs.displayModal.toggle
                                        }, 'Voltar')
                                    ),
                                    m('.w-col.w-col-1')
                                ])
                            ])
                        ]);
                    }
                };
                return [wrapper, customAttrs];
            },
            searchToChargebackPayments = () => {
                if (chargebackIds() != undefined && chargebackIds() != '') {
                    searchChargebackLoader(true);
                    m.redraw();
                    toChargebackListVM.pageSize(30);
                    toChargebackListVM.getPageWithToken({ gateway: 'eq.Pagarme', gateway_id: `in.(${generateIdsToData().join(',')})` }).then((data) => {
                        toChargebackCollection(data);
                        searchChargebackLoader(false);
                        displayChargebackConfirmationModal(true);
                        m.redraw();
                        toChargebackListVM.pageSize(10);
                    });
                }
            },
            processChargebacks = () => {
                if (generateIdsToData() != null && generateIdsToData().length >= 0) {
                    processChargebacksLoader(true);
                    m.redraw();
                    m.request({
                        method: 'POST',
                        url: '/admin/contributions/batch_chargeback',
                        data: {
                            gateway_payment_ids: generateIdsToData()
                        },
                        config: h.setCsrfToken
                    }).then((data) => {
                        processChargebacksLoader(false);
                        displayChargebackForm(false);
                        displayChargebackConfirmationModal(false);
                        submit(); // just to reload the contribution list
                    });
                }
            },
            inputActions = () => m('', [
                m('.w-inline-block', [
                    m('button.btn-inline.btn.btn-small.btn-terciary', {
                        onclick: displayChargebackForm.toggle
                    }, 'Chargeback em massa'),
                        (displayChargebackForm() ? m('.dropdown-list.card.u-radius.dropdown-list-medium.zindex-10', [
                            m('.w-form', [
                                (processChargebacksLoader()
                                    ? h.loader()
                                    : m('form', {onsubmit: searchToChargebackPayments }, [
                                        m('label.fontsize-small', 'Insira os IDs do gateway separados por vírgula'),
                                        m('textarea.text-field.w-input', { oninput: m.withAttr('value', chargebackIds) }),
                                        m('button.btn.btn-small.w-button', 'Virar apoios para chargeback')
                                    ])
                                )
                            ])
                        ]) : '')
                ])
            ]);

        vnode.state = {
            filterVM,
            filterBuilder,
            displayChargebackConfirmationModal,
            chargebackConfirmationModalContentWrapper,
            processChargebacks,
            listVM: {
                list: listVM,
                hasInputAction: true,
                inputActions,
                error
            },
            data: {
                label: 'Apoios'
            },
            submit
        };
    },

    view: function({state}) {
        return m('', [
            (state.displayChargebackConfirmationModal() ? m(modalBox, {
                displayModal: state.displayChargebackConfirmationModal,
                content: state.chargebackConfirmationModalContentWrapper({
                    modalTitle: 'Aprovar chargebacks',
                    ctaText: 'Aprovar',
                    displayModal: state.displayChargebackConfirmationModal,
                    onClickCallback: state.processChargebacks
                })
            }) : ''),
            m('#admin-root-contributions', [
                m(adminFilter, {
                    form: state.filterVM.formDescriber,
                    filterBuilder: state.filterBuilder,
                    submit: state.submit
                }),
                m(adminList, {
                    vm: state.listVM,
                    listItem: adminContributionItem,
                    listDetail: adminContributionDetail
                })
            ])
        ]);
    }
};

export default adminContributions;
