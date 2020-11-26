import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import popNotification from '../c/pop-notification';
import { RewardsEditList } from './projects/edit/rewards-edit-list';

const I18nScope = _.partial(h.i18nScope, 'projects.reward_fields');

const projectEditReward = {
    oninit: function(vnode) {
        const loading = prop(false);
        const error = prop(false);
        const errors = prop([]);
        const showSuccess = prop(false);
        const tips = window.I18n.translations[window.I18n.currentLocale()].projects.reward_fields.faq;

        vnode.state = {
            loading,
            error,
            errors,
            showSuccess,
            tips,
        };
    },

    view({ state, attrs }) {
        const project_id = attrs.project_id;
        const user_id = attrs.user_id;
        const error = state.error;
        const errors = state.errors;
        const project = attrs.project;
        const showSuccess = state.showSuccess;
        const loading = state.loading;

        return m('[id="dashboard-rewards-tab"]',
            (project() ? [
                m('.w-section.section',
                    m('.w-container', [
                        (state.showSuccess() ? m(popNotification, {
                            message: 'Recompensa salva com sucesso'
                        }) : ''),
                        (state.error() ? m(popNotification, {
                            message: state.errors(),
                            error: true
                        }) : ''),
                        m('.w-row',
                            m('.w-col.w-col-8.w-col-push-2',
                                m('.u-marginbottom-60.u-text-center',
                                    m('.w-inline-block.card.fontsize-small.u-radius', [
                                        m('span.fa.fa-lightbulb-o'),
                                        m.trust(` ${window.I18n.t('reward_know_more_cta_html', I18nScope())}`)
                                    ])
                                )
                            )
                        ),
                        m('.w-row', [
                            m('.w-col.w-col-8',
                                m(RewardsEditList, {
                                    class: 'card',
                                    project_id,
                                    user_id,
                                    project,
                                    error,
                                    errors,
                                    showSuccess,
                                    loading,
                                })
                            ),
                            m('.w-col.w-col-4',
                                m('.card.u-radius', [
                                    m('.fontsize-small.u-marginbottom-20', [
                                        m('span.fa.fa-lightbulb-o.fa-lg'),
                                        m.trust(` ${window.I18n.t('reward_know_more_cta_html', I18nScope())}`)
                                    ]),
                                    m('.divider.u-marginbottom-20'),
                                    m('.fontsize-smallest.w-hidden-small.w-hidden-tiny', [
                                        window.I18n.t('reward_faq_intro', I18nScope()),
                                        m('br'),
                                        m('br'),
                                        window.I18n.t('reward_faq_sub_intro', I18nScope()),
                                        m('br'),
                                        m('br'),
                                        _.map(state.tips,
                                            (tip, idx) => project().mode === 'sub' && (Number(idx) === 3 || Number(idx) === 4) ?
                                                null 
                                                :
                                                [
                                                    m('.fontweight-semibold', tip.title),
                                                    m.trust(tip.description),
                                                    m('br'),
                                                    m('br')
                                                ]
                                        )
                                    ])
                                ])
                            )
                        ])
                    ])
                )
            ] : h.loader())
        );
    }
};

export default projectEditReward;
