import m from 'mithril';

const filterNumber = {
    view: function({attrs}) {
        return m('.w-col.w-col-3.w-col-small-6', [
            m(`label.fontsize-smaller[for="${attrs.index}"]`, attrs.label),
            m('.w-row', [
                m('.w-col.w-col-12.w-col-small-12.w-col-tiny-12', [
                    m(`input.w-input.text-field.positive[id="${attrs.index}"][type="text"]`, {
                        placeholder: attrs.placeholder || '',
                        onchange: m.withAttr('value', attrs.first),
                        value: attrs.first()
                    })
                ]),
            ])
        ]);
    }
};

export default filterNumber;
