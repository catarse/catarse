import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import { catarse } from '../api';

const adminInputAction = {
    oninit: function(vnode) {
        const builder = vnode.attrs.data,
            complete = prop(false),
            error = prop(false),
            fail = prop(false),
            data = {},
            item = vnode.attrs.item,
            key = builder.property,
            forceValue = builder.forceValue || null,
            newValue = prop(forceValue);

        h.idVM.id(item[builder.updateKey]);

        const l = catarse.loaderWithToken(builder.model.patchOptions(h.idVM.parameters(), data));

        const updateItem = function (res) {
            console.log('SUBMIT SUCCESS!!!', res);
            _.extend(item, res[0]);
            complete(true);
            error(false);
        };

        const errorOnSubmit = () => {
            console.log('SOME ERROR HAPPENED!!!');
            complete(true);
            error(true);
        };

        const submit = function () {
            console.log('IS SUBMITTING!!!!!!!!');
            data[key] = newValue();
            return l.load().then(updateItem, errorOnSubmit);
        };

        const unload = function () {
            complete(false);
            error(false);
            newValue(forceValue);
        };

        vnode.state = {
            complete,
            error,
            l,
            newValue,
            submit,
            toggler: h.toggleProp(false, true),
            unload
        };
    },
    view: function({state, attrs}) {
        const data = attrs.data,
            btnValue = (state.l()) ? 'por favor, aguarde...' : data.callToAction;

        return m('.w-col.w-col-2', [
            m('button.btn.btn-small.btn-terciary', {
                onclick: state.toggler.toggle
            }, data.outerLabel), (state.toggler()) ?
            m('.dropdown-list.card.u-radius.dropdown-list-medium.zindex-10', {
                onremove: state.unload
            }, [
                m('form.w-form', {
                    onsubmit: state.submit
                }, (!state.complete()) ? [
                    m('label', data.innerLabel), (data.forceValue === undefined) ?
                    m(`input.w-input.text-field[type="text"][placeholder="${data.placeholder}"]`, {
                        onchange: m.withAttr('value', state.newValue),
                        value: state.newValue()
                    }) : '',
                    m(`input.w-button.btn.btn-small[type="submit"][value="${btnValue}"]`)
                ] : (!state.error()) ? [
                    m('.w-form-done[style="display:block;"]', [
                        m('p', data.successMessage)
                    ])
                ] : [
                    m('.w-form-error[style="display:block;"]', [
                        m('p', `Houve um problema na requisição. ${data.errorMessage}`)
                    ])
                ])
            ]) : ''
        ]);
    }
};

export default adminInputAction;
