import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const dateFieldMask = _.partial(h.mask, '99/99/9999');

const filterDateRange = {
    view: function({attrs}) {
        return m('.w-col.w-col-3.w-col-small-6', [
            m(`label.fontsize-smaller[for="${attrs.index}"]`, attrs.label),
            m('.w-row', [
                m('.w-col.w-col-5.w-col-small-5.w-col-tiny-5', [
                    m(`input.w-input.text-field.positive[id="${attrs.index}"][type="text"]`, {
                        onkeyup: m.withAttr('value', _.compose(attrs.first, dateFieldMask)),
                        value: attrs.first()
                    })
                ]),
                m('.w-col.w-col-2.w-col-small-2.w-col-tiny-2', [
                    m('.fontsize-smaller.u-text-center.lineheight-looser', 'e')
                ]),
                m('.w-col.w-col-5.w-col-small-5.w-col-tiny-5', [
                    m('input.w-input.text-field.positive[type="text"]', {
                        onkeyup: m.withAttr('value', _.compose(attrs.last, dateFieldMask)),
                        value: attrs.last()
                    })
                ])
            ])
        ]);
    }
};

export default filterDateRange;
