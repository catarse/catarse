import m from 'mithril';
import _ from 'underscore';

const dropdown = {
    view: function({attrs}) {
        const opts = (_.isFunction(attrs.options) ? attrs.options() : attrs.options);

        return m(
            `select${attrs.classes}[id="${attrs.id}"]`,
            {
                onchange: (e) => { attrs.valueProp(e.target.value); attrs.onchange(); },
                value: attrs.valueProp()
            },
            _.map(opts, data => m('option', { value: data.value }, data.option))
        );
    }
};

export default dropdown;
