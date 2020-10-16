import m from 'mithril';

const filterText = {
    view: function ({attrs}) {
        const buttonOptions = {};

        if ('onclick' in attrs)
            buttonOptions.onclick = attrs.onclick;

        return m(attrs.wrapper_class, [
            m('.fontsize-smaller.u-text-center',
                attrs.label
            ),
            m('.w-row', [
                m('.text-field.positive.prefix.no-hover.w-col.w-col-2.w-col-small-2.w-col-tiny-2',
                    m('a.w-inline-block[href=\'#\']', buttonOptions,
                        m('img.header-lupa[src=\'/assets/catarse_bootstrap/lupa_grey.png\']')
                    )
                ),
                m('.w-col.w-col-10.w-col-small-10.w-col-tiny-10',
                    m(`input.text-field.postfix.positive.w-input[maxlength='256'][placeholder='${attrs.placeholder}'][type='text']`, {
                        onchange: m.withAttr('value', attrs.vm),
                        value: attrs.vm()
                    })
                )
            ])
        ]);       
    }
};

export default filterText;
