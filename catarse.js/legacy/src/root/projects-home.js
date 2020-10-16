import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import homeVM, { HomeBanner, HomeVM } from '../vms/home-vm';
import slider from '../c/slider';
import projectsDisplay from '../c/projects-display';
import blogBanner from './blog-banner';
import UnsignedFriendFacebookConnect from '../c/unsigned-friend-facebook-connect';
import { HomeBannerSlide } from '../c/home-banner-slide';
const I18nScope = _.partial(h.i18nScope, 'projects.home');

const projectsHome = {
    oninit: function(vnode) {
        const userFriendVM = catarse.filtersVM({ user_id: 'eq' }),
            friendListVM = catarse.paginationVM(models.userFriend, 'user_id.desc', {
                Prefer: 'count=exact'
            }),
            currentUser = h.getUser() || {},
            hasFBAuth = currentUser.has_fb_auth,
            vm = homeVM();

        userFriendVM.user_id(currentUser.user_id);

        if (hasFBAuth && !friendListVM.collection().length) {
            friendListVM.firstPage(userFriendVM.parameters());
        }

        vnode.state = {
            vm,
            hasFBAuth
        };
    },
    view: function({state}) {
        /** @type {HomeVM} */
        const vm = state.vm;
        const banners = vm.banners;

        return m('#projects-home-component', {
            oncreate: h.setPageTitle(window.I18n.t('header_html', I18nScope())) 
        }, [
            m(slider, {
                slides: banners,
                slideComponent: HomeBannerSlide,
                effect: 'fade',
                slideClass: 'hero-slide start',
                wrapperClass: 'hero-full hero-full-slide',
                sliderTime: 10000
            }),
            m(projectsDisplay),
            (!state.hasFBAuth ? m(UnsignedFriendFacebookConnect, { largeBg: true }) : ''),
            m(blogBanner)
        ]);
    }
};

export default projectsHome;
