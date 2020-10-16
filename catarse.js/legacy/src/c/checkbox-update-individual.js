import m from 'mithril';

const checkboxUpdateIndividual = {
    view: function ({attrs}) {
        return m('.w-checkbox.fontsize-smallest.fontcolor-secondary.u-margintop-10', [
            m('input.w-checkbox-input[type="checkbox"]', {
                checked: attrs.current_state,
                onclick: attrs.onToggle
            }),
            m('label.w-form-label', attrs.text)
        ]);
    }
};

export default checkboxUpdateIndividual;