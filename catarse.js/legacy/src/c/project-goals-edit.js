import m from 'mithril';
import prop from 'mithril/stream';
import models from '../models';
import _ from 'underscore';
import h from '../h';
import {
    commonAnalytics
} from '../api';
import projectGoalEditCard from './project-goal-edit-card';
import projectGoalCard from './project-goal-card';
import projectGoalsVM from '../vms/project-goals-vm';
import popNotification from './pop-notification';
import generateErrorInstance from '../error';
import railsErrorsVM from '../vms/rails-errors-vm';

const I18nScope = _.partial(h.i18nScope, 'projects.dashboard_goal');

const projectGoalsEdit = {
    oninit: function(vnode) {
        const e = generateErrorInstance();
        const mapErrors = [
            ['goals', ['goals.size']]
        ];
        const goals = projectGoalsVM.goals;

        const l = commonAnalytics.loaderWithToken(models.projectSubscribersInfo.postOptions({
            id: vnode.attrs.project.common_id
        }));

        const currentGoal = prop();
        const subscribersDetails = prop({});
        l.load().then((subData) => {
            try {
                subscribersDetails(subData);
                const sortedGoals = _.sortBy(goals(), g => g().value());
                const nextGoal = _.find(sortedGoals, goal => goal().value() > subscribersDetails().amount_paid_for_valid_period);
                currentGoal(nextGoal());
            } catch(e) {

            }
        });
        const showSuccess = prop(false);
        const error = prop(false);

        projectGoalsVM.fetchGoalsEdit(vnode.attrs.projectId);

        if (railsErrorsVM.railsErrors()) {
            railsErrorsVM.mapRailsErrors(railsErrorsVM.railsErrors(), mapErrors, e);
        }
        vnode.state = {
            showSuccess,
            e,
            error,
            goals,
            currentGoal,
            addGoal: projectGoalsVM.addGoal
        };
    },

    view: function({state, attrs}) {
        const showSuccess = state.showSuccess,
            error = state.error;
        return m('.w-container',
            m('.w-row', [
                (state.showSuccess() ? m(popNotification, {
                    message: 'Meta salva com sucesso'
                }) : ''),
                (state.error() ? m(popNotification, {
                    message: 'Erro ao salvar informações',
                    error: true
                }) : ''),

                m('.w-col.w-col-8',
                    m('.w-form', [
                        state.e.inlineError('goals'),
                        m('div',
                            m(".card.card-terciary.medium.u-marginbottom-30[id='arrecadacao']", [
                                m('.u-marginbottom-30', [
                                    m("label.fontsize-base.fontweight-semibold[for='name-8']",
                                        'O que você vai alcançar com os pagamentos mensais de seus assinantes?'
                                    ),
                                    m('.fontsize-smaller', [
                                        'As metas mensais são a melhor maneira de informar aos seus assinantes como os recursos arrecadados mensalmente serão usados e o que vocês estão conquistando juntos.',
                                        m.trust('&nbsp;'),
                                        'Você pode alterar suas metas a qualquer momento durante sua campanha.'
                                    ])
                                ]),
                                _.map(state.goals(), (goal) => {
                                    if (goal().editing()) {
                                        return m(projectGoalEditCard, {
                                            goal,
                                            showSuccess,
                                            project: attrs.project,
                                            currentGoal: state.currentGoal,
                                            error
                                        });
                                    }
                                    return m(projectGoalCard, {
                                        goal
                                    });
                                }),
                                m('button.btn.btn-large.btn-message', {
                                    onclick: () => {
                                        state.addGoal(attrs.projectId);
                                    }
                                }, [
                                    '+ ',
                                    m.trust('&nbsp;'),
                                    ' Adicionar meta mensal'
                                ])
                            ])
                        )
                    ])
                ),
                m('.w-col.w-col-4',
                  m('.card.u-radius',
                      [
                          m('.fontsize-small.u-marginbottom-20',
                              [
                                  m('span.fa.fa-lightbulb-o.fa-lg'),
                                  m.trust('&nbsp;'),
                                  'Dicas'
                              ]
                      ),
                          m('ul.w-list-unstyled',
                              [
                                  m('li.u-marginbottom-10',
                            m('a.fontsize-smaller.alt-link[href="https://suporte.catarse.me/hc/pt-br/articles/360023830672-O-que-%C3%A9-a-meta-mensal-inicial-"][target="_blank"]',
                              'O que é a meta mensal inicial?'
                            )
                          ),
                                  m('li.u-marginbottom-10',
                            m('a.fontsize-smaller.alt-link[href="https://suporte.catarse.me/hc/pt-br/articles/360023830912-O-que-s%C3%A3o-as-metas-mensais-futuras-"][target="_blank"]',
                              'O que são as metas mensais futuras?'
                            )
                          ),
                                  m('li.u-marginbottom-10',
                            m('a.fontsize-smaller.alt-link[href="https://suporte.catarse.me/hc/pt-br/articles/360024085911-O-que-%C3%A9-a-meta-mensal-atual-"][target="_blank"]',
                              'O que é a meta mensal atual?'
                            )
                          ),
                                  m('li.u-marginbottom-10',
                            m('a.fontsize-smaller.alt-link[href="https://suporte.catarse.me/hc/pt-br/articles/360023831492-Posso-adicionar-novas-metas-depois-do-lan%C3%A7amento-"][target="_blank"]',
                              'Posso adicionar novas metas depois do lançamento?'
                            )
                          ),
                                  m('li.u-marginbottom-10',
                            m('a.fontsize-smaller.alt-link[href="https://suporte.catarse.me/hc/pt-br/articles/360024086591-O-que-acontece-se-eu-n%C3%A3o-atingir-a-meta-do-meu-projeto-"][target="_blank"]',
                              'O que acontece se eu não atingir a meta do meu projeto?'
                            )
                          )
                              ]
                      )
                      ]
                  )
                )
            ])
        );
    }
};

export default projectGoalsEdit;
