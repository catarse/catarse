import m from 'mithril';
import h from '../h';
import modalBox from './modal-box';

const InfoProjectContributionLegend = {
    oninit: function(vnode) {
        vnode.state = {
            modalToggle: h.toggleProp(false, true)
        };
    },
    view: function({state, attrs}) {
        return m('span', [
            attrs.text,
            m.trust('&nbsp;'),
            m('a.fa.fa-question-circle.fontcolor-secondary[href="#"]', {
                onclick: state.modalToggle.toggle
            }, ''),
            (state.modalToggle() ? m(modalBox, {
                displayModal: state.modalToggle,
                content: attrs.content
            }) : '')
        ]);
    }
};

export default InfoProjectContributionLegend;
