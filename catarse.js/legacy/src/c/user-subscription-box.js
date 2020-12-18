import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import moment from 'moment';
import models from '../models';
import { catarse } from '../api';
import contributionVM from '../vms/contribution-vm';
import subscriptionVM from '../vms/subscription-vm';
import commonPaymentVM from '../vms/common-payment-vm';
import ownerMessageContent from '../c/owner-message-content';
import subscriptionStatusIcon from '../c/subscription-status-icon';
import paymentMethodIcon from '../c/payment-method-icon';
import cancelSubscriptionContent from '../c/cancel-subscription-content';
import modalBox from '../c/modal-box';
import checkboxUpdateIndividual from '../c/checkbox-update-individual';
import userVM from '../vms/user-vm';
import userSubscriptionPaymentHistoryModal from './user-subscription-payment-history-modal';
import subscriptionNextChargeDateCompact from './subscription-next-charge-date-compact';
import userSubscriptionBoxControl from './user-subscription-box-control';

const I18nScope = _.partial(h.i18nScope, 'payment.state');
const contributionScope = _.partial(h.i18nScope, 'users.contribution_row');
const subscriptionScope = _.partial(h.i18nScope, 'users.subscription_row');

const userSubscriptionBox = {
    oninit: function(vnode) {
        const subscription = vnode.attrs.subscription,
            displayModal = h.toggleProp(false, true),
            displayCancelModal = h.toggleProp(false, true),
            displayPaymentHistoryModal = h.toggleProp(false, true),
            contactModalInfo = prop({}),
            isGeneratingSecondSlip = h.toggleProp(false, true);

        const filterProjVM = catarse
                .filtersVM({
                    project_id: 'eq',
                })
                .project_id(subscription.project_external_id),
            lProj = catarse.loaderWithToken(models.project.getRowOptions(filterProjVM.parameters()));

        lProj.load().then(arr => {
            subscription.project = arr[0];
            contactModalInfo({
                id: subscription.project.project_user_id,
                name: subscription.project.owner_name,
                project_id: subscription.project.project_id,
            });

            h.redraw();
        });

        if (subscription.payment_method === 'boleto' && subscription.last_payment_id) {
            commonPaymentVM.paymentInfo(subscription.last_payment_id).then(info => {
                subscription.boleto_url = info.boleto_url;
                subscription.boleto_expiration_date = info.boleto_expiration_date;
                subscription.payment_status = info.status;
                h.redraw();
            });
        }

        if (subscription.reward_external_id) {
            const filterRewVM = catarse
                    .filtersVM({
                        id: 'eq',
                    })
                    .id(subscription.reward_external_id),
                lRew = catarse.loaderWithToken(models.rewardDetail.getRowOptions(filterRewVM.parameters()));

            lRew.load().then(arr => {
                subscription.reward = arr[0];
                h.redraw();
            });
        }

        // Generate second slip payment and wait for result to update the view. In case of timeout, reloads the page.
        const generateSecondSlip = () => {
            isGeneratingSecondSlip.toggle();
            commonPaymentVM
                .tryRechargeSubscription(subscription.id)
                .then(info => {
                    subscription.boleto_url = info.boleto_url;
                    subscription.boleto_expiration_date = info.boleto_expiration_date;
                    subscription.payment_status = info.status;
                    isGeneratingSecondSlip.toggle();
                    h.redraw();
                })
                .catch(e => {
                    window.location.reload();
                });
        };

        const showLastSubscriptionVersionValueIfHasOne = () => {
            const is_active = subscription.status === 'active';
            const current_paid_subscription = subscription.current_paid_subscription;
            const last_paid_sub_amount = is_active || !current_paid_subscription ? subscription.checkout_data.amount : current_paid_subscription.amount;

            // has some subscription edition
            if (is_active && current_paid_subscription && current_paid_subscription.amount != subscription.checkout_data.amount) {
                const paid_value = parseFloat(current_paid_subscription.amount) / 100;
                const next_value = parseFloat(subscription.checkout_data.amount) / 100;
                return [
                    `R$ ${h.formatNumber(paid_value)} por mês`,
                    m('span.badge.badge-attention', [m('span.fa.fa-arrow-right', ''), m.trust('&nbsp;'), `R$ ${h.formatNumber(next_value)}`]),
                ];
            }

            const paid_value = parseFloat(last_paid_sub_amount) / 100;
            return [`R$ ${h.formatNumber(paid_value)} por mês`];

            return '';
        };

        const showLastSubscriptionVersionPaymentMethodIfHasOne = () => {
            const is_active = subscription.status === 'active';
            const current_paid_subscription = subscription.current_paid_subscription;
            const last_paid_sub_data = is_active || !current_paid_subscription ? subscription : current_paid_subscription;

            if (is_active && current_paid_subscription && subscription.checkout_data.payment_method != current_paid_subscription.payment_method) {
                return [
                    m(subscriptionStatusIcon, { subscription }),
                    m.trust('&nbsp;&nbsp;&nbsp;'),
                    m(paymentMethodIcon, { subscription: current_paid_subscription }),
                    m('span.badge.badge-attention.fontweight-semibold', [
                        m('span.fa.fa-arrow-right', ''),
                        m.trust('&nbsp;'),
                        m(paymentMethodIcon, { subscription }),
                    ]),
                ];
            }

            return [m(subscriptionStatusIcon, { subscription }), m.trust('&nbsp;&nbsp;&nbsp;'), m(paymentMethodIcon, { subscription: last_paid_sub_data })];

            return '';
        };

        const showLastSubscriptionVersionRewardTitleIfHasOne = () => {
            const is_active = subscription.status === 'active';
            const current_paid_subscription = subscription.current_paid_subscription;
            const current_reward_data = subscription.current_reward_data;
            const current_reward_id = subscription.current_reward_id;
            const last_paid_sub_data =
                is_active || !current_paid_subscription
                    ? subscription
                    : { reward: current_reward_data, reward_id: current_reward_id, reward_external_id: null };

            // first selection was no reward, but now selected one
            if (is_active && !current_reward_data && subscription.reward) {
                return [
                    ` ${window.I18n.t('no_reward', contributionScope())} `,
                    m.trust('&nbsp;'),
                    m(
                        '.fontsize-smallest.fontweight-semibold',
                        m('span.badge.badge-attention', [m('span.fa.fa-arrow-right', ''), m.trust('&nbsp;'), subscription.reward.title])
                    ),
                ];
            }
            // selected one rewared on subscription start, now selected another reward and last and current rewards are different
            else if (is_active && current_reward_data && subscription.reward && subscription.reward_id != current_reward_id) {
                const reward_description_formated = h.simpleFormat(`${h.strip(current_reward_data.description).substring(0, 90)} (...)`);
                return [
                    m('.fontsize-smallest.fontweight-semibold', current_reward_data.title),
                    m('p.fontcolor-secondary.fontsize-smallest', m.trust(reward_description_formated)),
                    m(
                        '.fontsize-smallest.fontweight-semibold',
                        m('span.badge.badge-attention', [m('span.fa.fa-arrow-right', ''), m.trust('&nbsp;'), subscription.reward.title])
                    ),
                ];
            }
            // no edition to rewards yet
            else if (last_paid_sub_data.reward) {
                const reward_description = h.strip(last_paid_sub_data.reward.description).substring(0, 90);
                const reward_description_formated = h.simpleFormat(`${reward_description} (...)`);
                return [
                    m('.fontsize-smallest.fontweight-semibold', last_paid_sub_data.reward.title),
                    m('p.fontcolor-secondary.fontsize-smallest', m.trust(reward_description_formated)),
                ];
            }
            // no editions to reward yet and no reward selected

            return [last_paid_sub_data.reward_external_id ? null : ` ${window.I18n.t('no_reward', contributionScope())} `];
        };

        const showLastSubscriptionVersionEditionNextCharge = () => {
            const current_reward_data = subscription.current_reward_data;
            const current_reward_id = subscription.current_reward_id;
            const current_paid_subscription = subscription.current_paid_subscription;

            if (
                current_paid_subscription &&
                (subscription.reward_id != current_reward_id ||
                    subscription.checkout_data.payment_method != current_paid_subscription.payment_method ||
                    subscription.checkout_data.amount != current_paid_subscription.amount)
            ) {
                const message = ` As alterações destacadas entrarão em vigor na próxima cobrança ${h.momentify(subscription.next_charge_at, 'DD/MM/YYYY')}.`;
                return m('.card-alert.fontsize-smaller.fontweight-semibold.u-marginbottom-10.u-radius', [
                    m('span.fa.fa-exclamation-triangle', ' '),
                    message,
                ]);
            }

            return '';
        };

        vnode.state = {
            toggleAnonymous: userVM.toggleAnonymous,
            displayModal,
            displayCancelModal,
            displayPaymentHistoryModal,
            subscription,
            contactModalInfo,
            showLastSubscriptionVersionValueIfHasOne,
            showLastSubscriptionVersionPaymentMethodIfHasOne,
            showLastSubscriptionVersionRewardTitleIfHasOne,
            showLastSubscriptionVersionEditionNextCharge,
            isGeneratingSecondSlip,
            generateSecondSlip,
        };
    },
    view: function({ state }) {
        const subscription = state.subscription,
            project = subscription.project;

        return !_.isEmpty(subscription) && !_.isEmpty(subscription.project)
            ? m(
                  'div',
                  state.displayCancelModal() && !_.isEmpty(state.contactModalInfo())
                      ? m(modalBox, {
                            displayModal: state.displayCancelModal,
                            content: [
                                cancelSubscriptionContent,
                                {
                                    displayModal: state.displayCancelModal,
                                    subscription,
                                },
                            ],
                        })
                      : '',
                  state.displayModal() && !_.isEmpty(state.contactModalInfo())
                      ? m(modalBox, {
                            displayModal: state.displayModal,
                            content: [ownerMessageContent, state.contactModalInfo()],
                        })
                      : '',
                  state.displayPaymentHistoryModal()
                      ? m(modalBox, {
                            displayModal: state.displayPaymentHistoryModal,
                            content: [userSubscriptionPaymentHistoryModal, { subscription, project }],
                        })
                      : '',
                  [
                      m('.card.w-row', [
                          m('.u-marginbottom-20.w-col.w-col-3', [
                              m('.u-marginbottom-10.w-row', [
                                  m(
                                      '.u-marginbottom-10.w-col.w-col-4',
                                      m(
                                          `a.w-inline-block[href='/${subscription.project.permalink}']`,
                                          m(
                                              `img.thumb-project.u-radius[alt='${subscription.project.project_name}'][src='${
                                                  subscription.project.project_img
                                              }'][width='50']`
                                          )
                                      )
                                  ),
                                  m(
                                      '.w-col.w-col-8',
                                      m('.fontsize-small.fontweight-semibold.lineheight-tight', [
                                          m(`a.link-hidden[href='/${subscription.project.permalink}']`, subscription.project.project_name),
                                          m('img[alt="Badge Assinatura"][src="/assets/catarse_bootstrap/badge-sub-h.png"]'),
                                      ])
                                  ),
                              ]),
                              m(
                                  "a.btn.btn-edit.btn-inline.btn-small.w-button[href='javascript:void(0);']",
                                  {
                                      onclick: () => {
                                          state.displayModal.toggle();
                                      },
                                  },
                                  window.I18n.t('contact_author', contributionScope())
                              ),
                          ]),
                          m('.u-marginbottom-20.w-col.w-col-3', [
                              m('.fontsize-base.fontweight-semibold.lineheight-tighter', state.showLastSubscriptionVersionValueIfHasOne()),
                              m(subscriptionNextChargeDateCompact, { subscription }),
                              m(
                                  '.fontcolor-secondary.fontsize-smaller.fontweight-semibold',
                                  `Iniciou há ${moment(subscription.created_at)
                                      .locale('pt')
                                      .fromNow(true)}`
                              ),
                              m('.u-marginbottom-10', state.showLastSubscriptionVersionPaymentMethodIfHasOne()),
                              m(
                                  'a.alt-link.fontsize-smallest[href="javascript:void(0);"]',
                                  {
                                      onclick: () => state.displayPaymentHistoryModal.toggle(),
                                  },
                                  'Histórico de pagamento'
                              ),
                              m(checkboxUpdateIndividual, {
                                  text: window.I18n.t('anonymous_sub', subscriptionScope()),
                                  current_state: subscription.checkout_data.anonymous,
                                  onToggle: () => subscriptionVM.toogleAnonymous(subscription),
                              }),
                          ]),
                          m('.u-marginbottom-20.w-col.w-col-3', state.showLastSubscriptionVersionRewardTitleIfHasOne()),
                          m(userSubscriptionBoxControl, {
                              subscription,
                              displayCancelModal: state.displayCancelModal,
                              isGeneratingSecondSlip: state.isGeneratingSecondSlip,
                              generateSecondSlip: state.generateSecondSlip,
                              showLastSubscriptionVersionEditionNextCharge: state.showLastSubscriptionVersionEditionNextCharge,
                          }),
                      ]),
                  ]
              )
            : m('div', '');
    },
};

export default userSubscriptionBox;
