import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import rewardVM from '../vms/reward-vm';
import popNotification from '../c/pop-notification';

const projectEditWelcome = {
    oninit: function(vnode) {
        const rewards = prop([]),
            currentRewardId = prop(),
            currentReward = prop(),
            showSuccess = prop(false),
            error = prop(false);

        const changeReward = () => {
            const reward = _.find(rewards(), r => r.id == currentRewardId());
            currentReward(reward);
            m.redraw();
        };

        const loadRewards = () => rewardVM.fetchRewards(vnode.attrs.project_id).then(() => {
            rewards([]);
            _.map(rewardVM.rewards(), (reward) => {
                const rewardProp = {
                    id: reward.id,
                    project_id: reward.project_id,
                    minimum_value: reward.minimum_value,
                    title: reward.title,
                    welcome_message_subject: prop(reward.welcome_message_subject || ''),
                    welcome_message_body: prop(reward.welcome_message_body || '')
                };
                rewards().push(rewardProp);
            });
            currentRewardId(_.first(rewards()).id);
            changeReward();
        });
        const validate = (reward) => {
            // if one field was filled both must be filled
            if (!_.isEmpty(reward.welcome_message_subject) || !_.isEmpty(reward.welcome_message_body)) {
                return !_.isEmpty(reward.welcome_message_subject) && !_.isEmpty(reward.welcome_message_body);
            }
            return true;
        };

        const updateRewards = () => {
            _.map(rewards(), (reward) => {
                const rewardData = {
                    id: reward.id,
                    welcome_message_subject: _.isEmpty(reward.welcome_message_subject()) ? null : reward.welcome_message_subject(),
                    welcome_message_body: _.isEmpty(reward.welcome_message_body()) ? null : reward.welcome_message_body()
                };
                if (validate(rewardData)) {
                    m.request({
                        method: 'PUT',
                        config: h.setCsrfToken,
                        url: `/projects/${reward.project_id}/rewards/${reward.id}.json`,
                        data: {
                            reward: rewardData
                        }
                    }).then(() => {
                        showSuccess(true);
                        m.redraw();
                    });
                } else {
                    error(true);
                    m.redraw();
                }
            });
        };

        loadRewards();

        vnode.state = {
            error,
            updateRewards,
            currentRewardId,
            showSuccess,
            currentReward,
            changeReward,
            rewards
        };
    },

    view: function({state, attrs}) {
        const error = state.error,
            project = attrs.project;
        return m("[id='dashboard-welcome-tab']",
            (project() ? [
                state.showSuccess() ? m(popNotification, {
                    message: 'Recompensas salvas com sucesso'
                }) : '',
                (state.error() ? m(popNotification, {
                    message: 'Erro ao salvar. Preencha todos os campos',
                    error: true
                }) : ''),
                m('.section',
                    m('.w-container',
                        m('.w-row', [
                            m('.w-col.w-col-1'),
                            m('.w-col.w-col-10',
                                m('.card.card-terciary.medium.u-marginbottom-30', [
                                    m('.fontsize-small.fontweight-semibold',
                                        'Escreva um email para cada faixa de assinante!'
                                    ),
                                    m('.fontsize-smaller.u-marginbottom-40',
                                        'Seus novos assinantes vão receber uma mensagem especial, assim que eles confirmarem o primeiro apoio ao seu projeto! Esse email é opcional, e você pode voltar aqui para editá-lo a qualquer momento.'
                                    ),
                                    m('.field-label.fontweight-semibold.u-marginbottom-10',
                                        'Recompensa'
                                    ),
                                    m('select.u-marginbottom-30.w-input.text-field.w-select.positive.medium', {
                                        onchange: (e) => {
                                            m.withAttr('value', state.currentRewardId)(e);
                                            state.changeReward();
                                        }
                                    }, [
                                        _.map(state.rewards(), reward =>
                                            m('option', {
                                                value: reward.id
                                            }, [
                                                m('div', [
                                                    m('span.fa.fa-fw',
                                                        ''
                                                    ),
                                                    m.trust('&nbsp;'),
                                                    `R$${reward.minimum_value} - ${reward.title}`
                                                ]),
                                                m('.w-icon-dropdown-toggle')
                                            ])
                                        )
                                    ]),
                                    state.currentReward() ?
                                    m('.w-form', [
                                        m('form', [
                                            m('.field-label.fontweight-semibold.u-marginbottom-10',
                                                'Título'
                                            ),
                                            m("input.text-field.positive.w-input[type='text']", {
                                                value: state.currentReward().welcome_message_subject(),
                                                onchange: m.withAttr('value', state.currentReward().welcome_message_subject)
                                            }),
                                            m('.field-label.fontweight-semibold.u-marginbottom-10',
                                                'Texto'
                                            ),
                                            m('textarea.text-field.height-medium.positive.u-marginbottom-60.w-input', {
                                                value: state.currentReward().welcome_message_body(),
                                                onchange: m.withAttr('value', state.currentReward().welcome_message_body)
                                            }),
                                            m('.u-marginbottom-20.w-row', [
                                                m('.w-col.w-col-3'),
                                                m('.w-sub-col.w-col.w-col-6',
                                                    m('a.btn.btn-large', {
                                                        onclick: state.updateRewards
                                                    },
                                                        'Salvar'
                                                    )
                                                ),
                                                m('.w-col.w-col-3')
                                            ])
                                        ])
                                    ]) : ''
                                ])
                            ),
                            m('.w-col.w-col-1')
                        ])
                    )
                )
            ] : h.loader())
        );
    }
};

export default projectEditWelcome;
