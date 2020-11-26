import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import { catarse } from '../api';

const adminRadioAction = {
    oninit: function(vnode) {
        const builder = vnode.attrs.data,
            complete = prop(false),
            data = {},
            error = prop(false),
            fail = prop(false),
            item = vnode.attrs.item(),
            description = prop(item.description || ''),
            key = builder.getKey,
            newID = prop(''),
            getFilter = {},
            setFilter = {},
            radios = prop(vnode.attrs.radios || []),
            getAttr = builder.radios,
            getKey = builder.getKey,
            getKeyValue = vnode.attrs.getKeyValue,
            updateKey = builder.updateKey,
            updateKeyValue = vnode.attrs.updateKeyValue,
            validate = builder.validate,
            selectedItem = builder.selectedItem || prop();

        setFilter[updateKey] = 'eq';
        const setVM = catarse.filtersVM(setFilter);
        setVM[updateKey](updateKeyValue);

        getFilter[getKey] = 'eq';
        const getVM = catarse.filtersVM(getFilter);
        getVM[getKey](getKeyValue);

        const getLoader = catarse.loaderWithToken(builder.getModel.getPageOptions(getVM.parameters()));

        const setLoader = catarse.loaderWithToken(builder.updateModel.patchOptions(setVM.parameters(), data));

        const updateItem = data => {
            if (data.length > 0) {
                const newItem = _.findWhere(radios(), {
                    id: data[0][builder.selectKey]
                });
                selectedItem(newItem);
            } else {
                error({
                    message: 'Nenhum item atualizado'
                });
            }
            complete(true);
            m.redraw();
        };

        const populateRadios = (data) => {
            const emptyState = builder.addEmpty;

            radios(data);

            if (!_.isUndefined(emptyState)) {
                radios().unshift(emptyState);
            }
        };

        const fetch = () => {
            getLoader.load().then(populateRadios, error);
        };

        const submit = () => {
            if (newID()) {
                const validation = validate(radios(), newID());
                if (_.isUndefined(validation)) {
                    data[builder.selectKey] = newID() === -1 ? null : newID();
                    setLoader.load().then(updateItem, error);
                } else {
                    complete(true);
                    error({
                        message: validation
                    });
                }
            }
            return false;
        };

        const unload = () => {
            complete(false);
            error(false);
            newID('');
        };

        const setDescription = (text) => {
            description(text);
            m.redraw();
        };

        fetch();

        vnode.state = {
            complete,
            description,
            setDescription,
            error,
            setLoader,
            getLoader,
            newID,
            submit,
            toggler: h.toggleProp(false, true),
            unload,
            radios
        };
    },
    view: function({state, attrs}) {
        const data = attrs.data,
            item = attrs.item(),
            btnValue = (state.setLoader() || state.getLoader()) ? 'por favor, aguarde...' : data.callToAction;

        return m('.w-col.w-col-2', [
            m('button.btn.btn-small.btn-terciary', {
                onclick: state.toggler.toggle
            }, data.outerLabel), (state.toggler()) ?
            m('.dropdown-list.card.u-radius.dropdown-list-medium.zindex-10', { onremove: state.unload }, [
                m('form.w-form', {
                    onsubmit: state.submit
                }, (!state.complete()) ? [
                    (state.radios()) ?
                    _.map(state.radios(), (radio, index) => m('.w-radio', [
                        m(`input#r-${index}.w-radio-input[type=radio][name="admin-radio"][value="${radio.id}"]`, {
                            checked: radio.id === (item[data.selectKey] || item.id),
                            onclick: () => {
                                state.newID(radio.id);
                                state.setDescription(radio.description);
                            }
                        }),
                        m(`label.w-form-label[for="r-${index}"]`, `R$${radio.minimum_value}`)
                    ])) : h.loader(),
                    m('strong', 'Descrição'),
                    m('p', state.description()),
                    m(`input.w-button.btn.btn-small[type="submit"][value="${btnValue}"]`)
                ] : (!state.error()) ? [
                    m('.w-form-done[style="display:block;"]', [
                        m('p', 'Recompensa alterada com sucesso!')
                    ])
                ] : [
                    m('.w-form-error[style="display:block;"]', [
                        m('p', state.error().message)
                    ])
                ])
            ]) : ''
        ]);
    }
};

export default adminRadioAction;
