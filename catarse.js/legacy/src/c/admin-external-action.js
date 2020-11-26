/**
 * window.c.AdminExternalAction component
 * Makes arbitrary ajax requests and update underlying
 * data from source endpoint.
 *
 * Example:
 * m.component(c.AdminExternalAction, {
 *     data: {},
 *     item: rowFromDatabase
 * })
 */
import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';

const adminExternalAction = {
    oninit: function(vnode) {
        let builder = vnode.attrs.data,
            complete = prop(false),
            error = prop(false),
            fail = prop(false),
            data = {},
            item = vnode.attrs.item;

        builder.requestOptions.config = (xhr) => {
            if (h.authenticityToken()) {
                xhr.setRequestHeader('X-CSRF-Token', h.authenticityToken());
            }
        };

        const reload = _.compose(builder.model.getRowWithToken, h.idVM.id(item[builder.updateKey]).parameters),
            l = prop(false);

        const reloadItem = () => reload().then(updateItem);

        const requestError = (err) => {
            l(false);
            complete(true);
            error(true);
        };

        const updateItem = (res) => {
            _.extend(item, res[0]);
            complete(true);
            error(false);
        };

        const submit = () => {
            console.log('Is submitting????');
            l(true);
            m.request(builder.requestOptions).then(reloadItem, requestError);
            return false;
        };

        const unload = () => {
            complete(false);
            error(false);
        };

        vnode.state = {
            l,
            complete,
            error,
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
            }, data.outerLabel), 
            
            (
                state.toggler() ?
                    m('.dropdown-list.card.u-radius.dropdown-list-medium.zindex-10', {
                        onremove: state.unload
                    }, [
                        m('form.w-form', {
                            onsubmit: state.submit
                        }, (!state.complete()) ? [
                            m('label', data.innerLabel),
                            m(`input.w-button.btn.btn-small[type="submit"][value="${btnValue}"]`)
                        ] : (!state.error()) ? [
                            m('.w-form-done[style="display:block;"]', [
                                m('p', 'Requisição feita com sucesso.')
                            ])
                        ] : [
                            m('.w-form-error[style="display:block;"]', [
                                m('p', 'Houve um problema na requisição.')
                            ])
                        ])
                    ]) 
                : 
                    ''
            )
        ]);
    }
};

export default adminExternalAction;
