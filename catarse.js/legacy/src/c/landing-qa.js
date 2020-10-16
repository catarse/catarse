/**
 * window.c.landingQA component
 * A visual component that displays a question/answer box with toggle
 *
 * Example:
 * view: () => {
 *      ...
 *      m.component(c.landingQA, {
 *          question: 'Whats your name?',
 *          answer: 'Darth Vader.'
 *      })
 *      ...
 *  }
 */
import m from 'mithril';
import h from '../h';

const landingQA = {
    oninit: function(vnode) {
        vnode.state = {
            showAnswer: h.toggleProp(false, true)
        };
    },
    view: function({state, attrs}) {
        return m('.card.qa-card.u-marginbottom-20.u-radius.btn-terciary', [
            m('.fontsize-base', {
                onclick: () => {
                    state.showAnswer.toggle();
                    attrs.onclick && attrs.onclick();
                }
            }, attrs.question),
            state.showAnswer() ? m('p.u-margintop-20.fontsize-small', m.trust(attrs.answer)) : ''
        ]);
    }
};

export default landingQA;
