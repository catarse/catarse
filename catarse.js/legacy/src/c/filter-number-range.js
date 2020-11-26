import m from 'mithril';

const filterNumberRange = {
    view: function({attrs}) {
        return m('.w-col.w-col-3.w-col-small-6', [
            m(`label.fontsize-smaller[for="${attrs.index}"]`, attrs.label),
            m('.w-row', [
                m('.w-col.w-col-5.w-col-small-5.w-col-tiny-5', [
                    m(`input.w-input.text-field.positive[id="${attrs.index}"][type="text"]`, {
                        onchange: m.withAttr('value', attrs.first),
                        value: attrs.first()
                    })
                ]),
                m('.w-col.w-col-2.w-col-small-2.w-col-tiny-2', [
                    m('.fontsize-smaller.u-text-center.lineheight-looser', 'e')
                ]),
                m('.w-col.w-col-5.w-col-small-5.w-col-tiny-5', [
                    m('input.w-input.text-field.positive[type="text"]', {
                        onchange: m.withAttr('value', attrs.last),
                        value: attrs.last()
                    })
                ])
            ])
        ]);
    }
};

export default filterNumberRange;
