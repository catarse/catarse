import m from 'mithril';

const DropdownMenu = {
    oninit(vnode) {

    },

    view({ state, attrs, children }) {

        const display = attrs.display ? 'block' : 'none';

        return m('.card.u-radius.zindex-10.dropdown-list.dropdown-list-medium.u-text-center', { style: { display } }, children);
    }
};

export default DropdownMenu;