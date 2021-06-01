import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import homeVM, { HomeBanner, HomeVM } from '../vms/home-vm';
import Slider from '../c/slider';
import ProjectsDisplay from '../c/projects-display';
import BlogBanner from './blog-banner';
import UnsignedFriendFacebookConnect from '../c/unsigned-friend-facebook-connect';
import { HomeBannerSlide } from '../c/home-banner-slide';
import { getCurrentUserCached } from '../shared/services/user/get-current-user-cached';
import { isLoggedIn } from '../shared/services/user/is-logged-in';
const I18nScope = _.partial(h.i18nScope, 'projects.home');

const projectsHome = {
    oninit: function(vnode: m.Vnode) {
        const userFriendVM = catarse.filtersVM({ user_id: 'eq' });
        const friendListVM = catarse.paginationVM(models.userFriend, 'user_id.desc', { Prefer: 'count=exact' });
        const currentUser = getCurrentUserCached();
        const hasFBAuth = isLoggedIn(currentUser) && currentUser.id && currentUser.has_fb_auth;
        const vm = homeVM();

        if (isLoggedIn(currentUser)) {
            userFriendVM.user_id(currentUser.id);
        }

        if (hasFBAuth && !friendListVM.collection().length) {
            friendListVM.firstPage(userFriendVM.parameters());
        }

        vnode.state = {
            vm,
            hasFBAuth
        };
    },
    view: function({state}) {
        const vm = state.vm as HomeVM;
        const banners = vm.banners;

        return (
            <div id="#projects-home-component" oncreate={h.setPageTitle(window.I18n.t('header_html', I18nScope()))}>
                <Slider
                    slides={banners}
                    slideComponent={HomeBannerSlide}
                    effect='fade'
                    slideClass='hero-slide start'
                    wrapperClass='hero-full hero-full-slide'
                    sliderTime={10000}
                />
                <ProjectsDisplay/>
                {
                    !state.hasFBAuth &&
                    <UnsignedFriendFacebookConnect largeBg={true}/>
                }
                <BlogBanner />
            </div>
        )
    }
};

export default projectsHome;
