import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const adminItem = {
    oninit: function(vnode) {
        vnode.state = {
            displayDetailBox: h.toggleProp(false, true)
        };
    },
    view: function({state, attrs}) {
        const item = attrs.item,
            listWrapper = attrs.listWrapper || {},
            selectedItem = (_.isFunction(listWrapper.isSelected) ?
                              listWrapper.isSelected(item.id) : false);


        return m('.w-clearfix.card.u-radius.u-marginbottom-20.results-admin-items', {
            class: (selectedItem ? 'card-alert' : '')
        }, [
            m(attrs.listItem, {
                item,
                listWrapper: attrs.listWrapper,
            }),
            m('button.w-inline-block.arrow-admin.fa.fa-chevron-down.fontcolor-secondary', {
                onclick: state.displayDetailBox.toggle
            }),
            (
                state.displayDetailBox() ? 
                    m(attrs.listDetail, {
                        item,
                    }) 
                : 
                    ''
            )
        ]);
    }
};

export default adminItem;
