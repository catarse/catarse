import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import contributionVM from '../vms/contribution-vm';
import ownerMessageContent from '../c/owner-message-content';
import modalBox from '../c/modal-box';
import userVM from '../vms/user-vm';
import rewardReceiver from './reward-receiver';
import paymentVM from '../vms/payment-vm';

const I18nScope = _.partial(h.i18nScope, 'payment.state');
const contributionScope = _.partial(h.i18nScope, 'users.contribution_row');

const userContributedBox = {
    oninit: function(vnode) {
        const displayModal = h.toggleProp(false, true),
            toggleDelivery = (projectId, contribution) => {
                userVM.toggleDelivery(projectId, contribution).then(() => {
                    const lastStatus = contribution.reward_sent_at ? 'delivered' : 'undelivered';
                    contribution.delivery_status = contribution.delivery_status === 'received' ? lastStatus : 'received'; // so we don't have to reload the page
                });
            },
            installmentTotalAmount = prop(h.formatNumber(vnode.attrs.contribution.installments_total_amount, 2));

        vnode.state = {
            toggleAnonymous: userVM.toggleAnonymous,
            displayModal,
            contribution: vnode.attrs.contribution,
            toggleDelivery,
            installmentTotalAmount
        };
    },
    view: function({state}) {
        const contribution = state.contribution,
            contactModalC = [ownerMessageContent, {
                id: contribution.project_user_id,
                name: contribution.project_owner_name,
                project_id: contribution.project_id
            }],
            finishedAt = contribution.survey && contribution.survey.finished_at,
            answeredAt = contribution.survey_answered_at;

        return (!_.isEmpty(contribution) ? m('div',
            (state.displayModal() ? m(modalBox, {
                displayModal: state.displayModal,
                content: contactModalC
            }) : ''), [
                m('.card.w-row', [
                    m('.u-marginbottom-20.w-col.w-col-3', [
                        m('.u-marginbottom-10.w-row', [
                            m('.u-marginbottom-10.w-col.w-col-4',
                                m(`a.w-inline-block[href='/${contribution.permalink}']`,
                                    m(`img.thumb-project.u-radius[alt='${contribution.project_name}'][src='${contribution.project_image}'][width='50']`)
                                )
                            ),
                            m('.w-col.w-col-8',
                                m('.fontsize-small.fontweight-semibold.lineheight-tight',
                                    m(`a.link-hidden[href='/${contribution.permalink}']`,
                                        contribution.project_name
                                    )
                                )
                            )
                        ]),
                        m("a.btn.btn-edit.btn-inline.btn-small.w-button[href='javascript:void(0);']", {
                            onclick: () => {
                                state.displayModal.toggle();
                            }
                        },
                            window.I18n.t('contact_author', contributionScope())
                        )
                    ]),
                    m('.u-marginbottom-20.w-col.w-col-3', [
                        m('.fontsize-base.fontweight-semibold.lineheight-looser',
                            `R$ ${contribution.value}`
                        ),
                        m('.w-embed',
                            m('div', [
                                m('.w-hidden-main.w-hidden-medium.fontsize-smallest.fontweight-semibold',
                                    window.I18n.t('status', contributionScope())
                                ),
                                m('.fontsize-smaller.fontweight-semibold', [
                                    m('.lineheight-tighter'),
                                    m(`span.fa.fa-circle.fontsize-smallest.${contribution.state === 'paid' ? 'text-success' : contribution.state === 'pending' ? 'text-waiting' : 'text-error'}`,
                                        m.trust('&nbsp;')
                                    ),
                                    window.I18n.t(`${contribution.payment_method.toLowerCase()}.${contribution.state}`, I18nScope({
                                        date: h.momentify(contribution[`${contribution.state}_at`])
                                    }))
                                ]),
                                m('.fontsize-smallest',
                                    (contribution.installments > 1 ? (`${contribution.installments} x R$ ${ h.formatNumber(contribution.installment_value, 2) } `) : ''),
                                    (contribution.payment_method === 'BoletoBancario' ? 'Boleto Bancário' : 'Cartão de Crédito')
                                ),
                                (
                                    contribution.installments > 1 ?
                                        m(".fontsize-smallest.fontweight-semibold.u-marginbottom-10",
                                            I18n.t('total_amount', contributionScope({
                                                total_amount: state.installmentTotalAmount()
                                            }))
                                        ) : ''
                                ),
                                (contributionVM.canShowReceipt(contribution) ?
                                    m(`a.alt-link.u-margintop-10[href='/projects/${contribution.project_id}/contributions/${contribution.contribution_id}/receipt'][target='__blank']`,
                                        window.I18n.t('show_receipt', contributionScope())
                                    ) : ''),

                                (contribution.gateway_data && contributionVM.canShowSlip(contribution) ?
                                    m(`a.alt-link.u-margintop-10[href='${contribution.gateway_data.boleto_url}'][target='__blank']`,
                                        window.I18n.t('print_slip', contributionScope())
                                    ) : ''),

                                (contribution.gateway_data && contributionVM.canGenerateSlip(contribution) ?
                                    m(`a.alt-link.u-margintop-10[href='/projects/${contribution.project_id}/contributions/${contribution.contribution_id}/second_slip'][target='__blank']`,
                                        window.I18n.t('slip_copy', contributionScope())
                                    ) : ''),
                                m('.w-checkbox.fontsize-smallest.fontcolor-secondary.u-margintop-10', [
                                    m(`input.w-checkbox-input[id='anonymous'][name='anonymous'][type='checkbox']${contribution.anonymous ? '[checked=\'checked\']' : ''}[value='1']`, {
                                        onclick: () => state.toggleAnonymous(contribution.project_id, contribution)
                                    }),
                                    m('label.w-form-label',
                                        window.I18n.t('anonymous', contributionScope())
                                    )
                                ])
                            ])
                        )
                    ]),
                    m('.u-marginbottom-20.w-col.w-col-3', [
                        (contribution.reward_id ?
                            [
                                m('.fontsize-smallest.fontweight-semibold', contribution.reward_title),
                                m('p.fontcolor-secondary.fontsize-smallest',
                                    m.trust(
                                        h.simpleFormat(
                                            `${h.strip(contribution.reward_description).substring(0, 90)} (...)`
                                        )
                                    )
                                )
                            ]
                            : ` ${window.I18n.t('no_reward', contributionScope())} `),
                        contribution.deliver_at ? m('.fontsize-smallest', [
                            m('span.fontweight-semibold',
                                `${window.I18n.t('delivery_estimate', contributionScope())} `
                            ),
                            h.momentify(contribution.deliver_at, 'MMMM/YYYY')
                        ]) : '',
                        contributionVM.canBeDelivered(contribution) ? m('.fontsize-smallest', [
                            m('span.fontweight-semibold',
                                window.I18n.t('delivery_status', contributionScope())
                            ),
                            m.trust('&nbsp;'),
                            h.contributionStatusBadge(contribution)
                        ]) : ''
                    ]),
                    m(rewardReceiver, {
                        contribution
                    }),
                    (contribution.survey ? [
                        (!answeredAt && finishedAt) ?
                        m('.u-text-center.w-col.w-col-2',
                            m('.fontsize-smaller.fontweight-semibold.lineheight-tighter',
                                m(`a.link-error[href='/contributions/${contribution.contribution_id}/surveys/${contribution.survey.survey_id}'][target='_blank']`, [
                                    m("span[xmlns='http://www.w3.org/1999/xhtml']"),
                                    m("span.fa.fa-exclamation-circle[xmlns='http://www.w3.org/1999/xhtml']",
                                        ''
                                    ),
                                    m.trust('&nbsp;'),
                                    'Questionário',
                                    m('br'),
                                    'Não respondido'
                                ])
                            )
                        ) : answeredAt ?
                        m('.u-text-center.w-col.w-col-2', [
                            m('.fontsize-smaller.fontweight-semibold.lineheight-tighter',
                                m(`a.link-hidden-dark[href='/contributions/${contribution.contribution_id}/surveys/${contribution.survey.survey_id}'][target='_blank']`, [
                                    'Questionário',
                                    m('br'),
                                    'Respondido'
                                ])
                            ),
                            m('.fontcolor-secondary.fontsize-smallest',
                                `em ${h.momentify(answeredAt, 'DD/MM/YYYY')}`
                            )
                        ]) :
                        m('.u-text-center.w-col.w-col-2',
                            m(`a.btn.w-button[href='/contributions/${contribution.contribution_id}/surveys/${contribution.survey.survey_id}']`,
                                window.I18n.t('answer_survey', contributionScope())
                            )
                        )
                    ] : '')
                ])
            ]
        ) : m('div', ''))
    }
};

export default userContributedBox;
