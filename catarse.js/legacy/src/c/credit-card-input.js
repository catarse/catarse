import m from 'mithril';
import prop from 'mithril/stream';
import creditCardVM from '../vms/credit-card-vm';

const creditCardInput = {
    oninit: function(vnode) {
        const cardType = vnode.attrs.type || prop('unknown');
        // TODO: move all input logic to vdom paradigm
        // CreditCard Input still handle events on a dom-based model.
        const cardNumberProp = vnode.attrs.value;
        const setCreditCardHandlers = (vnode) => {
            creditCardVM.setEvents(vnode.dom, cardType, cardNumberProp);
        };

        vnode.state = {
            setCreditCardHandlers,
            cardType
        };
    },
    view: function({state, attrs}) {
        return m(`input.w-input.text-field[name="${attrs.name}"][required="required"][type="tel"]`, {
            onfocus: attrs.onfocus,
            class: attrs.class,
            oncreate: state.setCreditCardHandlers,
            onblur: attrs.onblur
        });
    }
};

export default creditCardInput;
