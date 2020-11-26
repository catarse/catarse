import m from 'mithril';
import h from '../h';
import prop from 'mithril/stream';
import homeVM, { HomeBanner, HomeVM } from '../vms/home-vm';
import { AdminHomeBannersEntry } from '../c/admin-home-banners-entry';

const AdminHomeBanners = {
    oninit(vnode) {
        vnode.state = {
            vm: vnode.attrs.vm || homeVM()
        };
    },

    view({ state, attrs }) {

        /** @type {HomeVM} */
        const vm = state.vm;
        const banners = vm.banners;
        const isUpdating = vm.isUpdating;

        return m('span', [
            m('div.section',
                m('div.w-container',
                    m('div.fontsize-larger.u-text-center', 'Banners')
                )
            ),

            m('div.divider'),

            m('div.section.bg-gray.before-footer',
                m('div.w-container', [

                    vm.banners().map((banner, index) => {
                        const getterSetters = h.createPropAcessors(banner);
                        getterSetters.position = prop(index + 1);
                        return m(AdminHomeBannersEntry, getterSetters);
                    }),

                    m('div.u-marginbottom-60.w-row'),

                    m('div.save-draft-btn-section.w-row', [
                        m('div.w-col.w-col-4'),
                        m('div.w-col.w-col-4',
                            isUpdating ?
                                h.loader()
                                :
                                m('button.btn.btn-large[href=""]', { onclick: () => vm.updateBanners(banners()) }, 'Salvar')
                        ),
                        m('div.w-col.w-col-4')
                    ])
                ])
            )
        ]);
    }
};

export default AdminHomeBanners;