import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';
import _ from 'underscore';
import balanceTransferListVM from '../vms/balance-transfer-list-vm';
import balanceTransferFilterVM from '../vms/balance-transfer-filter-vm';
import adminList from '../c/admin-list';
import adminFilter from '../c/admin-filter';
import filterMain from '../c/filter-main';
import filterDropdown from '../c/filter-dropdown';
import filterDateRange from '../c/filter-date-range';
import filterNumberRange from '../c/filter-number-range';
import modalBox from '../c/modal-box';
import adminBalanceTransferItem from '../c/admin-balance-transfer-item';
import adminBalanceTransferItemDetail from '../c/admin-balance-transfer-item-detail';

const adminBalanceTranfers = {
    oninit: function(vnode) {
        const listVM = balanceTransferListVM,
            filterVM = balanceTransferFilterVM(),
            authorizedListVM = balanceTransferListVM,
            authorizedFilterVM = balanceTransferFilterVM(),
            authorizedCollection = prop([]),
            error = prop(''),
            selectedAny = prop(false),
            filterBuilder = [
                {
                    component: filterMain,
                    data: {
                        vm: filterVM.full_text_index,
                        placeholder: 'Busque pelo email, ids do usuario, ids de transferencia e eventos de saldo'
                    }
                },
                {
                    component: filterDropdown,
                    data: {
                        label: 'Status',
                        name: 'state',
                        vm: filterVM.state,
                        options: [{
                            value: '',
                            option: 'Qualquer um'
                        }, {
                            value: 'pending',
                            option: 'Pendente'
                        }, {
                            value: 'authorized',
                            option: 'Autorizado'
                        }, {
                            value: 'processing',
                            option: 'Processando'
                        }, {
                            value: 'transferred',
                            option: 'Concluido'
                        }, {
                            value: 'error',
                            option: 'Erro'
                        }, {
                            value: 'rejected',
                            option: 'Rejeitado'
                        }, {
                            value: 'gateway_error',
                            option: 'Erro no gateway'
                        }]
                    }
                },
                {
                    component: filterDateRange,
                    data: {
                        label: 'Data da solicitação',
                        first: filterVM.created_date.gte,
                        last: filterVM.created_date.lte
                    }

                },
                {
                    component: filterDateRange,
                    data: {
                        label: 'Data da confirmação',
                        first: filterVM.transferred_date.gte,
                        last: filterVM.transferred_date.lte
                    }

                },
                {
                    component: filterNumberRange,
                    data: {
                        label: 'Valores entre',
                        first: filterVM.amount.gte,
                        last: filterVM.amount.lte
                    }
                }
            ],
            selectedItemsIDs = prop([]),
            displayApprovalModal = h.toggleProp(false, true),
            displayManualModal = h.toggleProp(false, true),
            displayRejectModal = h.toggleProp(false, true),
            displayProcessTransfer = h.toggleProp(false, true),
            processingTranfersLoader = h.toggleProp(false, true),
            selectAllLoading = prop(false),
            redrawProp = prop(false),
            actionMenuToggle = h.toggleProp(false, true),
            isSelected = item_id => _.find(selectedItemsIDs(), i => i.id == item_id),
            selectItem = (item) => {
                if (!_.find(selectedItemsIDs(), i => i.id == item.id)) {
                    selectedItemsIDs().push(item);
                }
                selectedAny(true);
            },
            unSelectItem = (item) => {
                const newIDs = _.reject(selectedItemsIDs(), i => i.id == item.id);
                selectedItemsIDs(newIDs);
                if (_.isEmpty(newIDs)) {
                    selectedAny(false);
                }
            },
            loadAuthorizedBalances = () => {
                authorizedFilterVM.state('authorized');
                authorizedFilterVM.getAllBalanceTransfers(authorizedFilterVM).then((data) => {
                    authorizedCollection(data);
                    m.redraw();
                });
            },
            submit = () => {
                error(false);
                listVM.firstPage(filterVM.parameters()).then(_ => m.redraw(), (serverError) => {
                    error(serverError.message);
                    m.redraw();
                });

                return false;
            },
            generateWrapperModal = (customAttrs) => {
                const wrapper = {
                    view: function({state, attrs}) {
                        actionMenuToggle(false);
                        return m('', [
                            m('.modal-dialog-header', [
                                m('.fontsize-large.u-text-center', attrs.modalTitle)
                            ]),
                            m('.modal-dialog-content', [
                                m('.w-row.fontweight-semibold', [
                                    m('.w-col.w-col-6', 'Nome'),
                                    m('.w-col.w-col-3', 'Valor'),
                                    m('.w-col.w-col-3', 'Solicitado em'),
                                ]),
                                _.map(selectedItemsIDs(), (item, index) => m('.divider.fontsize-smallest.lineheight-looser', [
                                    m('.w-row', [
                                        m('.w-col.w-col-6', [
                                            m('span', item.user_name)
                                        ]),
                                        m('.w-col.w-col-3', [
                                            m('span', `R$ ${h.formatNumber(item.amount, 2, 3)}`)
                                        ]),
                                        m('.w-col.w-col-3', [
                                            m('span', h.momentify(item.created_at))
                                        ]),
                                    ])
                                ])),
                                m('.w-row.fontweight-semibold.divider', [
                                    m('.w-col.w-col-6', 'Total'),
                                    m('.w-col.w-col-3',
                                        `R$ ${h.formatNumber(_.reduce(selectedItemsIDs(), (t, i) => t + i.amount, 0), 2, 3)}`),
                                    m('.w-col.w-col-3'),
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
            manualTransferSelectedIDs = () => {
                m.request({
                    method: 'POST',
                    url: '/admin/balance_transfers/batch_manual',
                    data: {
                        transfer_ids: _.uniq(_.map(selectedItemsIDs(), s => s.id))
                    },
                    config: h.setCsrfToken
                }).then((data) => {
                    selectedItemsIDs([]);
                    listVM.firstPage(filterVM.parameters());
                    displayManualModal(false);
                    m.redraw();
                });
            },
            approveSelectedIDs = () => {
                m.request({
                    method: 'POST',
                    url: '/admin/balance_transfers/batch_approve',
                    data: {
                        transfer_ids: _.uniq(_.map(selectedItemsIDs(), s => s.id))
                    },
                    config: h.setCsrfToken
                }).then((data) => {
                    selectedItemsIDs([]);
                    listVM.firstPage(filterVM.parameters());
                    loadAuthorizedBalances();
                    displayApprovalModal(false);
                    m.redraw();
                });
            },
            //processAuthorizedTransfers = () => {
            //    processingTranfersLoader(true);
            //    m.redraw();
            //    m.request({
            //        method: 'POST',
            //        url: '/admin/balance_transfers/process_transfers',
            //        data: {},
            //        config: h.setCsrfToken
            //    }).then((data) => {
            //        listVM.firstPage(filterVM.parameters());
            //        loadAuthorizedBalances();
            //        displayProcessTransfer(false);
            //        processingTranfersLoader(false);
            //        m.redraw();
            //    });
            //},
            rejectSelectedIDs = () => {
                m.request({
                    method: 'POST',
                    url: '/admin/balance_transfers/batch_reject',
                    data: {
                        transfer_ids: _.uniq(_.map(selectedItemsIDs(), s => s.id))
                    },
                    config: h.setCsrfToken
                }).then((data) => {
                    selectedItemsIDs([]);
                    displayRejectModal(false);
                    listVM.firstPage();
                    m.redraw();
                });
            },
            unSelectAll = () => {
                selectedItemsIDs([]);
                selectedAny(false);
            },
            selectAll = () => {
                selectAllLoading(true);
                m.redraw();
                filterVM.getAllBalanceTransfers(filterVM).then((data) => {
                    _.map(_.where(data, { state: 'pending' }), selectItem);
                    selectAllLoading(false);
                    m.redraw();
                });
            },
            inputActions = () => {
                const authorizedSum = h.formatNumber(_.reduce(authorizedCollection(), (memo, item) => memo + item.amount, 0), 2, 3);
                return m('', [
                    m('button.btn.btn-inline.btn-small.btn-terciary.u-marginright-20.w-button', { onclick: selectAll }, (selectAllLoading() ? 'carregando...' : 'Selecionar todos')),
                      (selectedItemsIDs().length > 1 ? m('button.btn.btn-inline.btn-small.btn-terciary.u-marginright-20.w-button', { onclick: unSelectAll }, `Desmarcar todos (${selectedItemsIDs().length})`) : ''),
                      (selectedAny() ?
                       m('.w-inline-block', [
                           m('button.btn.btn-inline.btn-small.btn-terciary.w-button', {
                               onclick: actionMenuToggle.toggle
                           }, [
                               `Marcar como (${selectedItemsIDs().length})`,
                           ]),
                           (actionMenuToggle() ?
                            m('.card.dropdown-list.dropdown-list-medium.u-radius.zindex-10[id=\'transfer\']', [
                                m('a.dropdown-link.fontsize-smaller[href=\'javascript:void(0);\']', {
                                    onclick: event => displayApprovalModal.toggle()
                                }, 'Aprovada'),
                                m('a.dropdown-link.fontsize-smaller[href=\'javascript:void(0);\']', {
                                    onclick: event => displayManualModal.toggle()
                                }, 'Transferencia manual'),
                                m('a.dropdown-link.fontsize-smaller[href=\'javascript:void(0);\']', {
                                    onclick: event => displayRejectModal.toggle()
                                }, 'Recusada')
                            ]) : '')
                       ]) : ''),
                    //(authorizedCollection().length > 0 ? m('._w-inline-block.u-right', [
                    //    m('button.btn.btn-small.btn-inline', {
                    //        onclick: displayProcessTransfer.toggle
                    //    }, `Repassar saques aprovados (${authorizedCollection().length})`),
                    //    (displayProcessTransfer() ? m('.dropdown-list.card.u-radius.dropdown-list-medium.zindex-10', [
                    //        m('.w-form', [
                    //            (processingTranfersLoader() ? h.loader() : m('form', [
                    //                m('label.fontsize-smaller.umarginbottom-20', `Tem certeza que deseja repassar ${authorizedCollection().length} saques aprovados (total de R$ ${authorizedSum}) ?`),
                    //                m('button.btn.btn-small', {
                    //                    onclick: processAuthorizedTransfers
                    //                }, 'Repassar saques aprovados')
                    //            ]))
                    //        ])
                    //    ]) : '')
                    //]) : '')
                ]);
            };

        loadAuthorizedBalances();

        vnode.state = {
            displayApprovalModal,
            displayRejectModal,
            displayManualModal,
            displayProcessTransfer,
            authorizedCollection,
            generateWrapperModal,
            approveSelectedIDs,
            manualTransferSelectedIDs,
            //processAuthorizedTransfers,
            rejectSelectedIDs,
            filterVM,
            filterBuilder,
            listVM: {
                hasInputAction: true,
                inputActions,
                list: listVM,
                selectedItemsIDs,
                selectItem,
                unSelectItem,
                selectedAny,
                isSelected,
                redrawProp,
                error
            },
            data: {
                label: 'Pedidos de saque'
            },
            submit
        };
    },
    view: function({state, attrs}) {
        return m('', [
            m(adminFilter, {
                filterBuilder: state.filterBuilder,
                submit: state.submit
            }),
            (state.displayApprovalModal() ? m(modalBox, {
                displayModal: state.displayApprovalModal,
                content: state.generateWrapperModal({
                    modalTitle: 'Aprovar saques',
                    ctaText: 'Aprovar',
                    displayModal: state.displayApprovalModal,
                    onClickCallback: state.approveSelectedIDs
                })
            }) : ''),
            (state.displayManualModal() ? m(modalBox, {
                displayModal: state.displayManualModal,
                content: state.generateWrapperModal({
                    modalTitle: 'Transferencia manual de saques',
                    ctaText: 'Aprovar',
                    displayModal: state.displayManualModal,
                    onClickCallback: state.manualTransferSelectedIDs
                })
            }) : ''),
            (state.displayRejectModal() ? m(modalBox, {
                displayModal: state.displayRejectModal,
                content: state.generateWrapperModal({
                    modalTitle: 'Rejeitar saques',
                    ctaText: 'Rejeitar',
                    displayModal: state.displayRejectModal,
                    onClickCallback: state.rejectSelectedIDs
                })
            }) : ''),
            m(adminList, {
                vm: state.listVM,
                listItem: adminBalanceTransferItem,
                listDetail: adminBalanceTransferItemDetail
            })
        ]);
    }
};

export default adminBalanceTranfers;
