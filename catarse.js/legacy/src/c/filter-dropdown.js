import m from 'mithril';
import _ from 'underscore';
import dropdown from './dropdown';

const filterDropdown = {
    view: function({attrs}) {
        const wrapper_c = attrs.wrapper_class || '.w-col.w-col-3.w-col-small-6';
        return m(wrapper_c, [
            m(`label.fontsize-smaller[for="${attrs.index}"]`,
              (attrs.custom_label ? m(attrs.custom_label[0], attrs.custom_label[1]) : attrs.label)),
            m(dropdown, {
                id: attrs.index,
                onchange: _.isFunction(attrs.onchange) ? attrs.onchange : Function.prototype,
                classes: '.w-select.text-field.positive',
                valueProp: attrs.vm,
                options: attrs.options
            })
        ]);
    }
};

export default filterDropdown;
