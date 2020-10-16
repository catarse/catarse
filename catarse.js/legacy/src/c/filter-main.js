import m from 'mithril';

const filterMain = {
    view: function({attrs}) {
        const wrapper_c = attrs.wrapper_class || '.w-row';
        const inputWrapperClass = attrs.inputWrapperClass || '.w-input.text-field.positive.medium',
            btnClass = attrs.btnClass || '.btn.btn-large.u-marginbottom-10';

        return m(wrapper_c, [
            m('.w-col.w-col-8', [
                m(`input${inputWrapperClass}[placeholder="${attrs.placeholder}"][type="text"]`, {
                    onchange: m.withAttr('value', attrs.vm),
                    value: attrs.vm()
                })
            ]),
            m('.w-col.w-col-4', [
                m(`input#filter-btn${btnClass}[type="submit"][value="Buscar"]`)
            ])
        ]);
    }
};

export default filterMain;
