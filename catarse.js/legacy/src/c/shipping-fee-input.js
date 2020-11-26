import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import inlineError from '../c/inline-error';

const shippingFeeInput = {
    oninit: function(vnode) {
        const states = vnode.attrs.states;
        const fee = vnode.attrs.fee,
            fees = vnode.attrs.fees,
            deleted = h.toggleProp(false, true),
            stateInUse = stateData => {
                const destinations = _.map(fees(), fee => fee.destination());
                return stateData.acronym !== fee.destination() && _.contains(destinations, stateData.acronym);
            },
            applyMask = _.compose(fee.value, h.applyMonetaryMask);

        _.extend(fee, { deleted });
        const feeNumberValue = Number(fee.value());
        fee.value(feeNumberValue ? `${h.formatNumber(feeNumberValue, 2, 2)}` : '0,00');
        vnode.state = {
            fee,
            applyMask,
            fees,
            deleted,
            feeValue: fee.value,
            stateInUse,
            states
        };
    },
    view: function({state}) {
        const deleted = state.deleted,
            othersCount = _.filter(state.fees(), fee => fee.destination !== 'others' && fee.destination !== 'international').length,
            states = state.states;

        return m(`div${deleted() ? '.w-hidden' : ''}`, [
            m('.u-marginbottom-10.w-row', [
                m('.w-col.w-col-6',

                    (
                        state.fee.destination() === 'others' ? [

                            m('input[type=\'hidden\']', {
                                value: 'others'
                            }),
                            m('label.field-label.fontsize-smallest',
                                (othersCount > 0 ? 'Resto do Brasil' : 'Todos os estados do Brasil')
                            )
                        ] :

                        state.fee.destination() === 'international' ?

                        [
                            m('input[type=\'hidden\']', {
                                value: 'international'
                            }),
                            m('label.field-label.fontsize-smallest',
                                'Internacional'
                            )
                        ] :

                        m('select.fontsize-smallest.text-field.text-field-light.w-select', {
                            class: state.fee.error ? 'error' : false,
                            value: state.fee.destination(),
                            onchange: m.withAttr('value', state.fee.destination)
                        }, [
                            (_.map(states(), stateData =>
                                m('option', {
                                    value: stateData.acronym,
                                    disabled: state.stateInUse(stateData)
                                },
                                    stateData.name
                                )))
                        ]))
                ),
                m('.w-col.w-col-1'),
                m('.w-col.w-col-4',
                    m('.w-row', [
                        m('.no-hover.positive.prefix.text-field.w-col.w-col-3',
                            m('.fontcolor-secondary.fontsize-mini.u-text-center',
                                'R$'
                            )
                        ),
                        m('.w-col.w-col-9',
                            m('input.positive.postfix.text-field.w-input', {
                                value: state.applyMask(state.feeValue()),
                                autocomplete: 'off',
                                type: 'text',
                                onkeyup: m.withAttr('value', state.applyMask),
                                oninput: m.withAttr('value', state.feeValue)
                            })
                        )
                    ])
                ),
                m('.w-col.w-col-1', [
                    m('input[type=\'hidden\']', {
                        value: state.deleted()
                    }),

                    (state.fee.destination() === 'others' || state.fee.destination() === 'international' ? '' :
                        m('a.btn.btn-no-border.btn-small.btn-terciary.fa.fa-1.fa-trash', {
                            onclick: () => state.deleted.toggle()
                        }))
                ])


            ],
            state.fee.error ? m(inlineError, { message: 'Estado não pode ficar em branco.' }) : ''
            ), m('.divider.u-marginbottom-10')
        ]);
    }
};

export default shippingFeeInput;
