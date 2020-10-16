import m from 'mithril';

const nationalityRadio = {
    oninit: function(vnode) {
        const defaultCountryID = vnode.attrs.defaultCountryID,
            defaultForeignCountryID = vnode.attrs.defaultForeignCountryID,
            international = vnode.attrs.international,
            fields = vnode.attrs.fields;

        const setNational = () => {
            fields.countryID(defaultCountryID);
            international(false);
        };

        const setInternational = () => {
            fields.countryID(defaultForeignCountryID); // USA
            international(true);
        };

        vnode.state = {
            international,
            setNational,
            setInternational
        };
    },
    view: function({state, attrs}) {
        const international = state.international,
            setNational = state.setNational,
            setInternational = state.setInternational;

        return m('div',
            m('.w-row', [
                m('.w-col.w-col-4',
                    m('.fontsize-small.fontweight-semibold',
                        'Nacionalidade:'
                    )
                ),
                m('.w-col.w-col-4',
                    m('.fontsize-small.w-radio', [
                        m("input.w-radio-input[name='nationality'][type='radio']", {
                            checked: !international(),
                            onclick: setNational
                        }),
                        m('label.w-form-label', {
                            onclick: setNational
                        }, 'Brasileiro (a)')
                    ])
                ),
                m('.w-col.w-col-4',
                    m('.fontsize-small.w-radio', [
                        m("input.w-radio-input[name='nationality'][type='radio']", {
                            checked: international(),
                            onclick: setInternational
                        }),
                        m('label.w-form-label', {
                            onclick: setInternational
                        }, 'International')
                    ])
                )
            ])
        );
    }
};

export default nationalityRadio;
