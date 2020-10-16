/**
 * copyTextInput component
 * Displays a text input that copies it's content on click
 *
 * Example of use:
 * view: () => {
 *   ...
 *   m.component(copyTextInput, {value: 'some value'})
 *   ...
 * }
 */
import m from 'mithril';
import prop from 'mithril/stream';
import select from 'select';
import popNotification from './pop-notification';

const copyTextInput = {
    oninit: function(vnode) {
        const showSuccess = prop(false);
        const setClickHandler = localVnode => {
            let copy;
            const el = localVnode.dom;
            const textarea = el.parentNode.previousSibling.firstChild;

            textarea.innerText = vnode.attrs.value; // This fixes an issue when instantiating multiple copy clipboard components
            el.onclick = () => {
                select(textarea);
                copy = document.execCommand('copy');
                if (copy) {
                    showSuccess(true);
                    m.redraw();
                } else {
                    textarea.blur();
                }
                return false;
            };
        };

        vnode.state = {
            setClickHandler,
            showSuccess
        };
    },
    view: function({state, attrs}) {
        return m('.clipboard.w-row', [
            m('.w-col.w-col-10.w-col-small-10.w-col-tiny-10', m('textarea.copy-textarea.text-field.w-input', {
                style: 'margin-bottom:0;'
            }, attrs.value)),
            m('.w-col.w-col-2.w-col-small-2.w-col-tiny-2', m('button.btn.btn-medium.btn-no-border.btn-terciary.fa.fa-clipboard.w-button', {
                oncreate: state.setClickHandler
            })),
            state.showSuccess() ? m(popNotification, { message: 'Link copiado' }) : ''
        ]);
    }
};

export default copyTextInput;
