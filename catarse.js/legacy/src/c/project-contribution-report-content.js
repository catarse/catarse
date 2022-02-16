import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import popNotification from './pop-notification';
import projectContributionReportContentCard from './project-contribution-report-content-card';
import projectsContributionReportVM from '../vms/projects-contribution-report-vm';
import modalBox from '../c/modal-box';
import deliverContributionModalContent from '../c/deliver-contribution-modal-content';
import errorContributionModalContent from '../c/error-contribution-modal-content';

const projectContributionReportContent = {
    oninit: function(vnode) {
        const showSelectedMenu = h.toggleProp(false, true),
            selectedAny = prop(false),
            showSuccess = prop(false),
            loading = prop(false),
            displayDeliverModal = h.toggleProp(false, true),
            displayErrorModal = h.toggleProp(false, true),
            selectedContributions = prop([]),
            deliveryMessage = prop(''),
            selectAll = () => {
                projectsContributionReportVM.getAllContributions(vnode.attrs.filterVM).then((data) => {
                    const exceptReceived = _.filter(data, contrib => contrib.delivery_status !== 'received');
                    selectedContributions().push(..._.pluck(exceptReceived, 'id'));
                    selectedContributions([...new Set(selectedContributions())]);
                    selectedAny(!_.isEmpty(exceptReceived));
                });
            },
            unselectAll = () => {
                selectedContributions([]);
                selectedAny(false);
            },
            updateStatus = (status) => {
                const data = {
                    contributions: selectedContributions(),
                    message: deliveryMessage(),
                    delivery_status: status
                };
                if (status === 'delivered') {
                    displayDeliverModal.toggle();
                } else if (status === 'error') {
                    displayErrorModal.toggle();
                }
                loading(true);
                showSelectedMenu.toggle();
                m.redraw();
                projectsContributionReportVM.updateStatus(data).then(() => {
                    loading(false);
                    showSuccess(true);
                    // update status so we don't have to reload the page
                    _.map(_.filter(vnode.attrs.list.collection(), contrib => _.contains(selectedContributions(), contrib.id)),
                          item => item.delivery_status = status);
                }).catch(() => {
                    m.redraw();
                });
                return false;
            };

        vnode.state = {
            showSuccess,
            selectAll,
            unselectAll,
            deliveryMessage,
            displayDeliverModal,
            displayErrorModal,
            updateStatus,
            loading,
            showSelectedMenu,
            selectedAny,
            selectedContributions
        };
    },
    view: function({state, attrs}) {
        const list = attrs.list;
        const isFailed = attrs.project().state === 'failed';

        return m('.w-section.bg-gray.before-footer.section', state.loading() ? h.loader() : [
              (state.displayErrorModal() ? m(modalBox, {
                  displayModal: state.displayErrorModal,
                  hideCloseButton: false,
                  content: [errorContributionModalContent, { project: attrs.project, displayModal: state.displayErrorModal, amount: state.selectedContributions().length, updateStatus: state.updateStatus, message: state.deliveryMessage }]
              }) : ''),
              (state.displayDeliverModal() ? m(modalBox, {
                  displayModal: state.displayDeliverModal,
                  hideCloseButton: false,
                  content: [deliverContributionModalContent, { project: attrs.project, displayModal: state.displayDeliverModal, amount: state.selectedContributions().length, updateStatus: state.updateStatus, message: state.deliveryMessage }]
              }) : ''),

            (state.showSuccess() ? m(popNotification, {
                message: 'As informações foram atualizadas'
            }) : ''),
            m('.w-container', [
                m('.u-marginbottom-40',
                    m('.w-row', [
                        m('.u-text-center-small-only.w-col.w-col-2',
                            m('.fontsize-base.u-marginbottom-10', [
                                m('span.fontweight-semibold',
                                    (list.isLoading() ? '' : list.total())
                                ),
                                ' apoios'
                            ])
                        ),
                        m('.w-col.w-col-6', isFailed ? '' : [
                            (!state.selectedAny() ?
                                m('button.btn.btn-inline.btn-small.btn-terciary.u-marginright-20.w-button', {
                                    onclick: state.selectAll
                                },
                                    'Selecionar todos'
                                ) :
                                m('button.btn.btn-inline.btn-small.btn-terciary.u-marginright-20.w-button', {
                                    onclick: state.unselectAll
                                },
                                    'Desmarcar todos'
                                )
                            ),
                            (state.selectedAny() ?
                                m('.w-inline-block', [
                                    m('button.btn.btn-inline.btn-small.btn-terciary.w-button', {
                                        onclick: state.showSelectedMenu.toggle
                                    }, [
                                        'Marcar como'
                                    ]),
                                    (state.showSelectedMenu() ?
                                        m('.card.dropdown-list.dropdown-list-medium.u-radius.zindex-10[id=\'transfer\']', [
                                            m('a.dropdown-link.fontsize-smaller[href=\'#\']', {
                                                onclick: () => state.displayDeliverModal.toggle()
                                            },
                                                'Enviada'
                                            ),
                                            m('a.dropdown-link.fontsize-smaller[href=\'#\']', {
                                                onclick: () => state.displayErrorModal.toggle()
                                            },
                                                'Erro no envio'
                                            )
                                        ]) : '')
                                ]) : '')
                        ]),
                        m('.w-clearfix.w-col.w-col-4',
                            m('a.alt-link.fontsize-small.lineheight-looser.u-right', { onclick: () => attrs.showDownloads(true) }, [
                                m('span.fa.fa-download',
                                    ''
                                ),
                                ' Baixar relatórios'
                            ])
                        )
                    ])
                ),

                _.map(list.collection(), (item) => {
                    const contribution = prop(item);
                    return m(projectContributionReportContentCard, {
                        project: attrs.project,
                        contribution,
                        selectedContributions: state.selectedContributions,
                        selectedAny: state.selectedAny
                    });
                })
            ]),
            m('.w-section.section.bg-gray', [
                m('.w-container', [
                    m('.w-row.u-marginbottom-60', [
                        m('.w-col.w-col-2.w-col-push-5', [
                            (!list.isLoading() ?
                                (list.isLastPage() ? '' : m('button#load-more.btn.btn-medium.btn-terciary', {
                                    onclick: list.nextPage
                                }, 'Carregar mais')) : h.loader())
                        ])
                    ])

                ])
            ])

        ]);
    }
};

export default projectContributionReportContent;
