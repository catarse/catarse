import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import {
    commonPayment,
    commonProject,
    commonNotification
} from '../api';
import h from '../h';
import models from '../models';

const adminSubscriptionDetail = {
    oninit: function(vnode) {
        const loadReward = () => {
            
            const reward = prop({});

            if (vnode.attrs.item.reward_id) {
                const rewardFilterVM = commonProject.filtersVM({ id: 'eq' });
                rewardFilterVM.id(vnode.attrs.item.reward_id);
                const rewardsLoader = commonProject.loaderWithToken(models.projectReward.getRowOptions(rewardFilterVM.parameters()));
                rewardsLoader
                    .load()
                    .then((data) => {
                        reward(_.first(data));
                        h.redraw();
                    });
            }

            return reward;
        };

        const filterVM = commonPayment.filtersVM({
            subscription_id: 'eq'
        });
        filterVM.subscription_id(vnode.attrs.key);
        const currentPayment = prop({});

        // Pagination on notifications
        const notificationsLoader = commonNotification.paginationVM(models.userNotification, 'created_at.desc');
        let isFirstPage = true;
        
        const loadNotifications = () => {
            const notificationsInternal = prop([]);            
            const addNotificationsToInternal = (notifications) => notificationsInternal(notifications);

            // First loads the first page and configure the next interactions
            if (isFirstPage)
            {
                const notificationFilterVM = commonNotification
                    .filtersVM({
                        user_id: 'eq',
                        project_id: 'eq'
                    }).order({
                        created_at: 'desc'
                    });
    
                notificationFilterVM.user_id(vnode.attrs.item.user_id);
                notificationFilterVM.project_id(vnode.attrs.item.project_id);
    
                notificationsLoader
                    .firstPage(notificationFilterVM.parameters())
                    .then(addNotificationsToInternalData => {
                        addNotificationsToInternal(addNotificationsToInternalData);
                        h.redraw();
                    });

                isFirstPage = false;
            }
            else
            {
                // Next pages set the notifications with all notifications got from endpoint
                notificationsLoader
                    .nextPage()
                    .then(addNotificationsToInternalData => {
                        addNotificationsToInternal(addNotificationsToInternalData);
                        h.redraw();
                    });
            }

            return notificationsInternal;
        };

        const loadTransitions = () => {
            const transitions = prop([]);
            const paymentTransitionsFilter = commonPayment
                .filtersVM({
                    subscription_id: 'eq',
                    project_id: 'eq'
                })
                .order({
                    created_at: 'desc'
                });

            paymentTransitionsFilter.subscription_id(vnode.attrs.item.id);
            paymentTransitionsFilter.project_id(vnode.attrs.item.project_id);

            const lPaymentTransitions = commonPayment
                .loaderWithToken(models.subscriptionTransition.getPageOptions(paymentTransitionsFilter.parameters()));

            lPaymentTransitions
                .load()
                .then(transitionsData => {
                    transitions(transitionsData);
                    h.redraw();
                });

            return transitions;
        };

        const loadPayments = () => {
            const payments = prop([]);
            const paymentsFilter = commonPayment
                .filtersVM({
                    subscription_id: 'eq',
                    project_id: 'eq'
                })
                .order({
                    created_at: 'desc'
                });

            paymentsFilter.subscription_id(vnode.attrs.item.id);
            paymentsFilter.project_id(vnode.attrs.item.project_id);

            models.commonPayments.pageSize(false);
            const lUserPayments = commonPayment.loaderWithToken(
                models.commonPayments.getPageOptions(paymentsFilter.parameters()));

            lUserPayments.load().then((data) => {
                currentPayment(_.first(data));
                _.map(data, (payment, i) => {
                    _.extend(payment, {
                        selected: prop(i === 0)
                    });
                });
                payments(data);

                h.redraw();
            });

            return payments;
        };

        const clearSelected = (payments) => {
            _.map(payments, (payment) => {
                payment.selected(false);
            });
        };

        vnode.state = {
            payments: loadPayments(),
            transitions: loadTransitions(),
            notifications: loadNotifications(),
            loadNotifications,
            notificationsLoader,
            currentPayment,
            clearSelected,
            reward: loadReward()
        };
    },
    view: function({state, attrs}) {
        const payments = state.payments(),
            transitions = state.transitions(),
            notifications = state.notifications(),
            reward = state.reward(),
            currentPayment = state.currentPayment;

        return m('.card.card-terciary.w-row', payments ? [
            m('.w-col.w-col-4',
                m('div', [
                    m('.fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-20',
                      'Histórico da transação'
                     ),
                    _.map(transitions, transition => m('.fontsize-smallest.lineheight-looser.w-row', [
                        m('.w-col.w-col-6',
                                m('div',
                                    h.momentify(transition.created_at, 'DD/MM/YYYY hh:mm')
                                )
                            ),
                        m('.w-col.w-col-6',
                                m('span',
                                    `${transition.from_status} -> ${transition.to_status}`
                                ))
                    ])),
                    m('.divider'),
                    _.map(payments, (payment, i) => m(`.fontsize-smallest.lineheight-looser.w-row${payment.selected() ? '.fontweight-semibold' : ''}`, [
                        m('.w-col.w-col-6',
                                m('div',
                                    h.momentify(payment.created_at, 'DD/MM/YYYY hh:mm')
                                )
                            ),
                        m('.w-col.w-col-6',
                                m(`span.${payment.selected() ? 'link-hidden-dark' : 'alt-link'}`, {
                                    onclick: () => {
                                        state.clearSelected(payments);
                                        payment.selected(true);
                                        currentPayment(payment);
                                    }
                                },
                                    payment.status
                                ))
                    ])),
                    m('.fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-20.u-margintop-20',
                      'Notificações'
                     ),
                    _.map(notifications, notification => m('.fontsize-smallest.lineheight-looser.w-row', [
                        m('.w-col.w-col-6',
                              m('div',
                                h.momentify(notification.created_at, 'DD/MM/YYYY hh:mm')
                               )
                             ),
                        m('.w-col.w-col-6',
                            m('span',
                                notification.label
                            )
                        )
                    ])),
                    m('.w-inline-block', 
                        (state.notificationsLoader.isLastPage() ? ''
                        : m('button.btn-inline.btn.btn-small.btn-terciary', { onclick: state.loadNotifications }, 'Carregar mais')))
                ])),
            m('.w-col.w-col-4',
                m('div', [
                    m('.fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-20',
                        'Detalhes do apoio mensal'
                    ),
                    m('.fontsize-smallest.lineheight-loose', currentPayment() ? [
                        `Início: ${h.momentify(currentPayment().created_at, 'DD/MM/YYYY hh:mm')}`,
                        m('br'),
                        `Confirmação: ${h.momentify(currentPayment().paid_at, 'DD/MM/YYYY hh:mm')}`,
                        m('br'),
                        `Valor: R$${currentPayment().amount / 100}`,
                        m('br'),
                        !_.isEmpty(reward) ? `Recompensa: R$${reward.data.minimum_value / 100} - ${reward.data.title} - ${reward.data.description.substring(0, 90)}(...)` : 'Sem recompensa',
                        m('br'),
                        `Id pagamento: ${currentPayment().id}`,
                        m('br'),
                        `Id gateway: ${currentPayment().gateway_id}`,
                        m('br'),
                        'Apoio:',
                        m.trust('&nbsp;'),
                        currentPayment().subscription_id,
                        m('br'),
                        currentPayment().payment_method === 'credit_card' ? [
                            'Cartão ',
                            m.trust('&nbsp;'),
                            `${currentPayment().payment_method_details.first_digits}******${currentPayment().payment_method_details.last_digits}`,
                            m.trust('&nbsp;'),
                            m.trust('&nbsp;'),
                            currentPayment().payment_method_details.brand
                        ] : 'Boleto'
                    ] : '')
                ])
            ),
            m('.w-col.w-col-4')
        ] : '');
    }
};

export default adminSubscriptionDetail;
