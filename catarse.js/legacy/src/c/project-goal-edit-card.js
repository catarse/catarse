import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import projectGoalsVM from '../vms/project-goals-vm';

const projectGoalEditCard = {
    oninit: function(vnode) {
        const goal = vnode.attrs.goal(),
            project = vnode.attrs.project,
            descriptionError = prop(false),
            titleError = prop(false),
            valueError = prop(false),
            validate = () => {
                vnode.attrs.error(false);
                descriptionError(false);
                valueError(false);
                if (_.isEmpty(goal.title())) {
                    vnode.attrs.error(true);
                    titleError(true);
                }
                if (_.isEmpty(goal.description())) {
                    vnode.attrs.error(true);
                    descriptionError(true);
                }
                if (!goal.value() || parseInt(goal.value()) < 10) {
                    vnode.attrs.error(true);
                    valueError(true);
                }
            };
        const destroyed = prop(false);

        const acceptNumeric = (e) => {
            goal.value(e.target.value.replace(/[^0-9]/g, ''));
            return true;
        };
        const confirmDelete = () => {
            const r = confirm('Você tem certeza?');
            if (r) {
                if (!goal.id()) {
                    destroyed(true);
                    return false;
                }
                return m.request({
                    method: 'DELETE',
                    url: `/projects/${goal.project_id()}/goals/${goal.id()}`,
                    config: h.setCsrfToken
                }).then(() => {
                    destroyed(true);
                    h.redraw();
                }).catch(() =>
                    alert('Erro ao deletar meta.')
                );
            }
            return false;
        };
        const saveGoal = () => {
            validate();
            if (vnode.attrs.error()) {
                return false;
            }
            const data = {
                id: goal.id(),
                project_id: goal.project_id(),
                value: goal.value(),
                title: goal.title(),
                description: goal.description()
            };

            if (goal.id()) {
                projectGoalsVM.updateGoal(goal.project_id(), goal.id(), data).then(() => {
                    vnode.attrs.showSuccess(true);
                    goal.editing.toggle();
                    h.redraw();
                });
            } else {
                projectGoalsVM.createGoal(goal.project_id(), data).then((r) => {
                    goal.id(r.goal_id);
                    vnode.attrs.showSuccess(true);
                    goal.editing.toggle();
                    h.redraw();
                });
            }
            return false;
        };
        vnode.state = {
            confirmDelete,
            descriptionError,
            titleError,
            valueError,
            acceptNumeric,
            destroyed,
            saveGoal
        };
    },
    view: function({state, attrs}) {
        const goal = attrs.goal(),
            inlineError = message => m('.fontsize-smaller.text-error.u-marginbottom-20.fa.fa-exclamation-triangle',
                m('span',
                    message
                )
            );

        return state.destroyed() ? m('div', '') :
            m('.card.u-marginbottom-30', [
                m('.w-row', [
                    m('.w-col.w-col-6',
                        m('.fontsize-small',
                            'Meta:'
                        )
                    ),
                    m('.w-col.w-col-6',
                        m('.w-row', [
                            m('.prefix.text-field.w-col.w-col-4.w-col-small-6.w-col-tiny-6',
                                m('.fontcolor-secondary.fontsize-base.lineheight-tightest.u-text-center',
                                    'R$'
                                )
                            ),
                            m('.w-col.w-col-8.w-col-small-6.w-col-tiny-6',
                                m("input.positive.postfix.text-field.w-input[type='text']", {
                                    class: state.valueError() ? 'error' : false,
                                    value: goal.value(),
                                    oninput: e => state.acceptNumeric(e),
                                    onchange: m.withAttr('value', goal.value)
                                })
                            )
                        ])
                    )
                ]),

                state.valueError() ? inlineError('A meta deve ser igual ou superior a R$10') : '',
                m('.w-row', [
                    m('.w-col.w-col-6',
                        m('.fontsize-small',
                            'Título:'
                        )
                    ),
                    m('.w-col.w-col-6',
                        m("input.positive.text-field.w-input[type='text']", {
                            value: goal.title(),
                            class: state.descriptionError() ? 'error' : false,
                            onchange: m.withAttr('value', goal.title)
                        })
                    )
                ]),
                state.titleError() ? inlineError('Título não pode ficar em branco.') : '',
                m('.w-row', [
                    m('.w-col.w-col-6',
                        m('.fontsize-small',
                            'Descrição da meta:'
                        )
                    ),
                    m('.w-col.w-col-6',
                        m("textarea.height-medium.positive.text-field.w-input[placeholder='O que você vai fazer se atingir essa meta?']", {
                            value: goal.description(),
                            class: state.descriptionError() ? 'error' : false,
                            onchange: m.withAttr('value', goal.description)
                        })
                    )
                ]),
                state.descriptionError() ? inlineError('Descrição não pode ficar em branco.') : '',
                m('.u-margintop-30.w-row', [
                    m('.w-sub-col.w-col.w-col-5',
                        m('button.btn.btn-small.w-button', {
                            onclick: state.saveGoal
                        }, 'Salvar')
                    ),
                    (attrs.goal().id() ?
                        m('.w-sub-col.w-col.w-col-6',
                            m('button.btn.btn-small.btn-terciary.w-button', {
                                onclick: () => {
                                    attrs.goal().editing.toggle();
                                }
                            }, 'Cancelar')
                        ) : ''),
                    m('.w-col.w-col-1',
                        m('button.btn.btn-inline.btn-no-border.btn-small.btn-terciary.fa.fa-lg.fa-trash', {
                            onclick: state.confirmDelete
                        })
                    )
                ])
            ]);
    }
};

export default projectGoalEditCard;
