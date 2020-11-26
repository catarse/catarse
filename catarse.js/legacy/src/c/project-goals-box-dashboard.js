import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';

const projectGoalsBoxDashboard = {
    oninit: function(vnode) {
        const initialGoalIndex = vnode.attrs.goalDetails().length > 0 ? _.findIndex(vnode.attrs.goalDetails(), goal => goal.value > vnode.attrs.amount) : 0;
        const currentGoalIndex = prop(initialGoalIndex);
        const nextGoal = () => {
            if (currentGoalIndex() < vnode.attrs.goalDetails().length - 1) {
                currentGoalIndex((currentGoalIndex() + 1));
            }
        };
        const previousGoal = () => {
            if (currentGoalIndex() > 0) {
                currentGoalIndex((currentGoalIndex() - 1));
                m.redraw();
            }
        };
        if (currentGoalIndex() === -1) {
            currentGoalIndex(vnode.attrs.goalDetails().length - 1);
        }
        vnode.state = {
            currentGoalIndex,
            nextGoal,
            previousGoal
        };
    },
    view: function({state, attrs}) {
        const goals = attrs.goalDetails().length > 0 ? attrs.goalDetails() : [{
                title: 'N/A',
                value: '',
                description: ''
            }],
            currentGoalIndex = state.currentGoalIndex,
            goalPercentage = (attrs.amount / goals[currentGoalIndex()].value) * 100;

        return m('.card.card-terciary.flex-column.u-marginbottom-10.u-radius.w-clearfix', [
            m('.u-right', [
                m('button.btn-inline.btn-terciary.fa.fa-angle-left.u-radius.w-inline-block', {
                    onclick: state.previousGoal,
                    class: currentGoalIndex() === 0 ? 'btn-desactivated' : ''
                }),
                m('button.btn-inline.btn-terciary.fa.fa-angle-right.u-radius.w-inline-block', {
                    onclick: state.nextGoal,
                    class: currentGoalIndex() === goals.length - 1 ? 'btn-desactivated' : ''
                })
            ]),
            m('.fontsize-small.u-marginbottom-10',
                    'Metas'
                ),
            m('.fontsize-largest.fontweight-semibold',
                    `${Math.floor(goalPercentage)}%`
                ),
            m('.meter.u-marginbottom-10',
                    m('.meter-fill', {
                        style: {
                            width: `${(goalPercentage > 100 ? 100 : goalPercentage)}%`
                        }
                    })
                ),
            m('.fontcolor-secondary.fontsize-smallest.fontweight-semibold.lineheight-tighter',
                    goals[currentGoalIndex()].title
                ),
            m('.fontcolor-secondary.fontsize-smallest',
                    `R$${attrs.amount} de R$${goals[currentGoalIndex()].value} por mês`
                )
        ]);
    }
};

export default projectGoalsBoxDashboard;
