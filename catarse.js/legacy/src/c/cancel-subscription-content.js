/**
 * window.c.cancelSubscriptionContent component
 * Render cancel subscription form
 *
 */
import m from 'mithril';
import prop from 'mithril/stream';
import {
    catarse,
    commonPayment
} from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';

const cancelSubscriptionContent = {
    oninit: function(vnode) {
        const canceling = prop(false);

        const cancelSubscription = () => {
            const l = commonPayment.loaderWithToken(models.cancelSubscription.postOptions({
                id: vnode.attrs.subscription.id
            }));
            l.load().then(() => {
                canceling(true);
                vnode.attrs.subscription.status = 'canceling';
                m.redraw();
            });
        };

        vnode.state = {
            cancelSubscription,
            canceling
        };
    },
    view: function({state, attrs}) {
        const successMessage = m('.modal-dialog-content', [
                m('.fontsize-megajumbo.u-text-center.u-marginbottom-20',
              '🙁'
             ),
                m('.fontsize-base.u-marginbottom-20', [
                    'Sua assinatura de ',
                    m('span.fontweight-semibold',
                  `R$${attrs.subscription.amount / 100}`
                 ),
                    ' para o projeto ',
                    m('span.fontweight-semibold',
                  attrs.subscription.project.project_name
                 ),
                    ` foi cancelada. Como sua próxima data de vencimento é no dia ${h.momentify(attrs.subscription.next_charge_at, 'DD/MM/YYYY')}, sua assinatura ainda estará ativa até este dia. Mas não se preocupe, que você não terá mais nenhuma cobrança em seu nome daqui pra frente.`,
                    m('br'),
                    m('br'),
                    'Se por algum motivo você quiser um reembolso de seu apoio mensal, entre em contato direto com ',
                    m(`a.alt-link[href='/users/${attrs.subscription.project.project_user_id}#about']`,
                  attrs.subscription.project.owner_name
                 ),
                    '.',
                    m('br'),
                    m('br'),
                    'Até logo!'
                ])
            ]),
            contactForm = [
                m('.modal-dialog-content', [
                    m('.modal-dialog-nav-bottom',
                        m('.w-row', [
                            m('.w-col.w-col-2'),
                            m('.u-text-center.w-col.w-col-5',
                                m('a.btn.btn-large.u-marginbottom-20', {
                                    onclick: state.cancelSubscription
                                },
                                    'Cancelar assinatura'
                                )
                            ),
                            m('.w-col.w-col-3',
                                m('a.btn.btn-large.u-marginbottom-20.btn-terciary.btn-no-border', {
                                    onclick: attrs.displayModal.toggle
                                },
                                    'Voltar'
                                )
                            ),
                            m('.w-col.w-col-2')
                        ])
                    ),
                    m('.fontsize-base', [
                        'Tem certeza que você quer solicitar o cancelamento de sua assinatura de ',
                        m('span.fontweight-semibold',
                            `R$${attrs.subscription.amount / 100}`
                        ),
                        ' para o projeto ',
                        m('span.fontweight-semibold',
                            attrs.subscription.project.project_name
                        ),
                        '?'
                    ])
                ])
            ];

        return m('div', [
            m('.modal-dialog-header',
                m('.fontsize-large.u-text-center', 'Cancelar sua assinatura')
            ),
            state.canceling() ? successMessage : contactForm
        ]);
    }
};

export default cancelSubscriptionContent;
