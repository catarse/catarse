import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import surveyVM from '../vms/survey-vm';
import projectDashboardMenu from '../c/project-dashboard-menu';
import rewardCardBig from '../c/reward-card-big';
import surveyCreatePreview from '../c/survey-create-preview';
import dashboardMultipleChoiceQuestion from '../c/dashboard-multiple-choice-question';
import dashboardOpenQuestion from '../c/dashboard-open-question';
import inlineError from '../c/inline-error';

const surveyCreate = {
    oninit: function(vnode) {
        const
            showError = prop(false),
            loader = catarse.loaderWithToken,
            showPreview = h.toggleProp(false, true),
            confirmAddress = surveyVM.confirmAddress,
            projectDetails = prop([]),
            rewardFilterVM = catarse.filtersVM({
                id: 'eq'
            }),
            filterVM = catarse.filtersVM({
                project_id: 'eq'
            }),
            {
                project_id,
                reward_id
            } = vnode.attrs;

        rewardFilterVM.id(reward_id);
        filterVM.project_id(project_id);
        const rewardVM = catarse.loaderWithToken(models.rewardDetail.getPageOptions(rewardFilterVM.parameters())),
            l = loader(models.projectDetail.getRowOptions(filterVM.parameters()));

        const reward = prop([]);
        l.load().then(projectDetails);
        rewardVM.load().then(reward);

        const choice = (type) => {

            switch(type) {
            case 'multiple': {
                return [
                    m('span.fa.fa-dot-circle-o'),
                    '  Múltipla escolha'
                ];
            }

            case 'open': {
                return [
                    m('span.fa.fa-align-left'),
                    '  Resposta aberta'
                ];
            }

            default: {
                return [
                    m('span.fa.fa-align-left'),
                    '  Resposta aberta'
                ];
            }
            }
        };

        const setQuestionType = (question, type) => () => {
            question.type = type;
            surveyVM.updateDashboardQuestion(question);
        };

        const choiceDropdown = question => {
            console.log('question to drop down', question);
            return m('.w-col.w-col-4.w-sub-col',
                m('.text-field.w-dropdown', {
                    onclick: () => {
                        question.toggleDropdown.toggle();
                        surveyVM.updateDashboardQuestion(question);
                    }
                }, [
                    m('.dropdown-toggle.w-dropdown-toggle', [
                        choice(question.type),
                        m('span.fa.fa-chevron-down.u-right')
                    ]),
                    m('.card.dropdown-list.w-dropdown-list', {
                        class: question.toggleDropdown() ? 'w--open' : null
                    }, [
                        m('span.dropdown-link.w-dropdown-link', {
                            onclick: setQuestionType(question, surveyVM.openQuestionType)
                        }, choice('open')),
                        m('span.dropdown-link.w-dropdown-link', {
                            onclick: setQuestionType(question, surveyVM.multipleQuestionType)
                        }, choice('multiple'))
                    ])
                ])
            );
        };

        const addDashboardQuestion = () => {
            surveyVM.addDashboardQuestion();

            return false;
        };

        const deleteDashboardQuestion = question => () => {
            surveyVM.deleteDashboardQuestion(question);

            return false;
        };

        const toggleShowPreview = () => {
            showError(false);

            if (surveyVM.isValid()) {
                h.scrollTop();
                showPreview(true);
            } else {
                showPreview(false);
                showError(true);
            }
        };

        const sendQuestions = () => {
            surveyVM.submitQuestions(reward_id).then(m.route.set(`/projects/${project_id}/surveys`)).catch(console.error);

            return false;
        };

        vnode.state = {
            reward,
            showError,
            showPreview,
            toggleShowPreview,
            project_id,
            confirmAddress,
            projectDetails,
            choiceDropdown,
            addDashboardQuestion,
            deleteDashboardQuestion,
            sendQuestions
        };
    },
    view({state}) {
        const project = _.first(state.projectDetails());
        const reward = _.first(state.reward());
        return [
            project ? 
                m('.project-surveys', [
                    (
                        project.is_owner_or_admin &&
                        m(projectDashboardMenu, {
                            project: prop(project)
                        })
                    ),
                    state.showPreview() ? 
                        m(surveyCreatePreview, {
                            confirmAddress: state.confirmAddress(),
                            showPreview: state.showPreview,
                            surveyVM,
                            reward,
                            sendQuestions: state.sendQuestions
                        })
                        : 
                        [
                            (
                                reward &&
                                m('.card-terciary.section.u-text-center',
                                    m('.w-container',
                                        m('.w-row', [
                                            m('.w-col.w-col-8.w-col-push-2',
                                                m('div', [
                                                    m('.fontsize-small.fontweight-semibold.u-marginbottom-20',
                                                        `Questionário para os ${reward.paid_count} apoiadores da recompensa`
                                                    ),
                                                    m(rewardCardBig, { reward })
                                                ])
                                            )
                                        ])
                                    )
                                )
                            ),
                            m('.divider'),
                            m('.section',
                                m('.w-row', [
                                    m('.w-col.w-col-10.w-col-push-1', [
                                        m('.card.card-terciary.medium.u-marginbottom-20.u-text-center', [
                                            m('.u-marginbottom-20', [
                                                m('.fontsize-base.fontweight-semibold.u-marginbottom-10',
                                                    'Confirmar endereço de entrega?'
                                                ),
                                                m('a.toggle.w-clearfix.w-inline-block', {
                                                    class: state.confirmAddress() ? 'toggle-on' : 'toggle-off',
                                                    onclick: state.confirmAddress.toggle
                                                }, [
                                                    m('.toggle-btn', {
                                                        class: state.confirmAddress() ? null : 'toggle-btn--off'
                                                    }),
                                                    state.confirmAddress() ? m('.u-right', 'SIM') : m('.u-left', 'NÃO')
                                                ]
                                                ),
                                                m('input[type="hidden"]', {
                                                    name: 'reward[surveys_attributes][confirm_address]'
                                                })
                                            ]),
                                            m('.w-row', [
                                                m('.w-col.w-col-8.w-col-push-2',
                                                    m('p.fontcolor-secondary.fontsize-small',
                                                        'Se essa recompensa será entregue na casa dos apoiadores, deixe essa opção como "SIM". Dessa forma, incluíremos uma pergunta no questionário para que eles confirmem o endereço de entrega.'
                                                    )
                                                )
                                            ])
                                        ]),
                                        _.map(surveyVM.dashboardQuestions(), (question, index) => m('.card.card-terciary.medium.u-marginbottom-20.w-row', [
                                            state.choiceDropdown(question),
                                            m('.w-clearfix.w-col.w-col-8', [
                                                (
                                                    question.type === 'multiple' ?
                                                        m(dashboardMultipleChoiceQuestion, {
                                                            question,
                                                            index
                                                        })
                                                        :
                                                        m(dashboardOpenQuestion, {
                                                            question,
                                                            index
                                                        })                
                                                ),
                                                m('button.btn.btn-inline.btn-no-border.btn-small.btn-terciary.fa.fa-lg.fa-trash.u-right', {
                                                    onclick: state.deleteDashboardQuestion(question)
                                                })
                                            ])

                                        ])),
                                        m('button.btn.btn-large.btn-message', {
                                            onclick: state.addDashboardQuestion
                                        }, [
                                            m('span.fa.fa-plus-circle'),
                                            '  Adicionar pergunta'
                                        ])
                                    ])
                                ])
                            ),
                            m('.section',
                                m('.w-container',
                                    m('.w-row', [
                                        m('.w-col.w-col-4.w-col-push-4',
                                            m('a.btn.btn-large[href=\'javascript:void(0);\']', {
                                                onclick: state.toggleShowPreview
                                            },
                                            'Pré-visualizar'
                                            ),
                                            state.showError()
                                                ? m('.u-text-center.u-margintop-10', m(inlineError, { message: 'Erro ao salvar formulário.' }))
                                                : null
                                        )
                                    ])
                                )
                            )
                        ]
                ])
                :
                h.loader()
        ];
    }
};

export default surveyCreate;
