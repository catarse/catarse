import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const filterDateField = {
    oninit: function(vnode) {
        vnode.state = {
            dateFieldMask: _.partial(h.mask, '99/99/9999')
        };
    },
    view: function({state, attrs}) {
        return m('.w-col.w-col-3.w-col-small-6', [
            m(`label.fontsize-smaller[for="${attrs.index}"]`, attrs.label),
            m(`input.w-input.text-field.positive[id="${attrs.index}"][type="text"]`, {
                onkeydown: m.withAttr('value', _.compose(attrs.vm, state.dateFieldMask)),
                value: attrs.vm()
            })
        ]);
    }
};

export default filterDateField;
