import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';
import _ from 'underscore';

const EnterKey = 13;

const innerFieldInput = {
    oninit: function(vnode) {
        const inputState = {
            value: vnode.attrs.inputValue,
            setValue: function(value) {
                value = (''+value).replace(/[^0-9]*/g, '');
                value = Math.abs(parseInt(value));
                inputState.value(value);
            }
        }

        vnode.state = { inputState };
    },
    view: function({state, attrs}) {
        const defaultInputOptions = {
            onchange: m.withAttr('value', state.inputState.setValue),
            value: state.inputState.value(),
            onkeyup: (e) => {
                if (e.keyCode == EnterKey) 
                    attrs.onsetValue();
                state.inputState.setValue(e.target.value)
            }
        };

        let inputExtraProps = '';

        if ('min' in attrs) inputExtraProps += `[min='${attrs.min}']`;
        if ('max' in attrs) inputExtraProps += `[max='${attrs.max}']`;
        if ('placeholder' in attrs) inputExtraProps += `[placeholder='${attrs.placeholder}']`;
        else inputExtraProps += `[placeholder=' ']`;

        return attrs.shouldRenderInnerFieldLabel ? 
            m(`input.text-field.positive.w-input[type='number']${inputExtraProps}`, defaultInputOptions)
                :
            m('.w-row', [
                m('.text-field.positive.prefix.no-hover.w-col.w-col-3.w-col-small-3.w-col-tiny-3',
                    m('.fontsize-smallest.fontcolor-secondary.u-text-center', attrs.label)
                ),
                m('.w-col.w-col-9.w-col-small-9.w-col-tiny-9',
                    m(`input.text-field.postfix.positive.w-input[type='number']${inputExtraProps}`, defaultInputOptions)
                )
            ]);
    }
}

const filterDropdownNumberRange = {
    oninit: function (vnode) {
        const
            firstValue = prop(0),
            secondValue = prop(0),
            clearFieldValues = () => { firstValue(0), secondValue(0) },
            getNumericValue = (value) => isNaN(value) ? 0 : value,
            getLowerValue = () => getNumericValue(firstValue()),
            getHigherValue = () => getNumericValue(secondValue()),
            renderPlaceholder = () => {
                const 
                    lowerValue = getLowerValue(),
                    higherValue = getHigherValue();

                let placeholder = vnode.attrs.value_change_placeholder;
                if (higherValue !== 0) placeholder = vnode.attrs.value_change_both_placeholder;

                if (lowerValue !== 0)
                {
                    placeholder = placeholder.replace('#V1', lowerValue);
                }
                else
                {
                    placeholder = placeholder.replace('#V1', vnode.attrs.init_lower_value);
                }
        
                if (higherValue !== 0)
                {
                    placeholder = placeholder.replace('#V2', higherValue);
                }
                else
                {
                    placeholder = placeholder.replace('#V2', vnode.attrs.init_higher_value);
                }
                return placeholder;
            },
            showDropdown = h.toggleProp(false, true);
        
        vnode.state = {
            firstValue, 
            secondValue, 
            clearFieldValues, 
            getLowerValue, 
            getHigherValue, 
            renderPlaceholder, 
            showDropdown
        };
    },
    view: function ({state, attrs}) {
        
        const dropdownOptions = {};
        const shouldRenderInnerFieldLabel = !!!attrs.inner_field_label;
        const applyValueToFilter = () => {
            const higherValue = state.getHigherValue() * attrs.value_multiplier;
            const lowerValue = state.getLowerValue() * attrs.value_multiplier;

            attrs.vm.gte(lowerValue);
            attrs.vm.lte(higherValue);
            attrs.onapply();
            state.showDropdown.toggle();
        };
        
        if ('dropdown_inline_style' in attrs) {
            dropdownOptions.style = attrs.dropdown_inline_style;
        }

        return m(attrs.wrapper_class, [
            m('.fontsize-smaller.u-text-center', attrs.label),
            m('div', {
                style: {'z-index' : '1'}
            }, [
                m('select.w-select.text-field.positive', {
                    style: {
                        'margin-bottom' : '0px'
                    },
                    onmousedown: function(e) {
                        e.preventDefault();
                        if (attrs.selectable() !== attrs.index && state.showDropdown()) state.showDropdown.toggle();
                        attrs.selectable(attrs.index);
                        state.showDropdown.toggle();
                    }
                },
                [
                    m('option', {
                        value: ''
                    }, state.renderPlaceholder())
                ]),
                ((state.showDropdown() && attrs.selectable() == attrs.index) ? 
                    m('nav.dropdown-list.dropdown-list-medium.card', dropdownOptions,
                    [
                        m('.u-marginbottom-20.w-row', [
                            m('.w-col.w-col-5.w-col-small-5.w-col-tiny-5',
                                m(innerFieldInput, {
                                    shouldRenderInnerFieldLabel,
                                    inputValue: state.firstValue,
                                    placeholder: attrs.inner_field_placeholder,
                                    label: attrs.inner_field_label,
                                    min: attrs.min,
                                    onsetValue: applyValueToFilter
                                })
                            ),
                            m('.w-col.w-col-2.w-col-small-2.w-col-tiny-2',
                                m('.fontsize-smaller.u-text-center.u-margintop-10',
                                    'a'
                                )
                            ),
                            m('.w-col.w-col-5.w-col-small-5.w-col-tiny-5',
                                m(innerFieldInput, {
                                    shouldRenderInnerFieldLabel,
                                    inputValue: state.secondValue,
                                    placeholder: ' ',
                                    label: attrs.inner_field_label,
                                    min: attrs.min,
                                    onsetValue: applyValueToFilter
                                })
                            )
                        ]),
                        m('a.fontsize-smaller.fontweight-semibold.alt-link.u-right[href=\'#\']', {
                            onclick: applyValueToFilter
                        }, 'Aplicar'),
                        m('a.fontsize-smaller.link-hidden[href=\'#\']', {
                            onclick: () => {
                                state.clearFieldValues();
                                applyValueToFilter();
                            }
                        }, 'Limpar')
                    ])

                : '')
            ])
        ]);
    }
}

export default filterDropdownNumberRange;
