import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import HeaderMenuSearch from '../c/header-menu-search';
import { UserProfileMenu } from '../c/user-profile-menu';
import models from '../models';
import { catarse } from '../api';
import { If } from '../shared/components/if';
import { ThisWindow, UserDetails } from '../entities';
import { withHooks } from 'mithril-hooks';

declare var window : ThisWindow

export const HeaderMenu = withHooks<HeaderMenuProps>(_HeaderMenu)

type HeaderMenuProps = {
    user: UserDetails
    menuShort?: boolean
    menuTransparency?: boolean
    withAlert?: boolean
    withFixedAlert?: boolean
    absoluteHome?: boolean
}

function _HeaderMenu(props : HeaderMenuProps) {

    const {
        user,
        absoluteHome,
        menuShort,
        menuTransparency,
        withAlert,
        withFixedAlert
    } = props

    const goToStart = () => m.route.set('/start')
    const goToExplore = (event : Event) => {
        event.preventDefault();
        m.route.set('/explore?ref=ctrse_header&filter=all')
    }

    const menuCSS = `${(menuTransparency ? ' overlayer ' : '')} ${((withAlert || withFixedAlert) ? ' with-global-alert ' : '')}`

    const homeUrl = absoluteHome ? h.rootUrl() : '/?ref=ctrse_header'

    return (
        <header class={`main-header ${menuCSS}`}>
            <div class="w-row">
                <div class="w-clearfix w-col w-col-8 w-col-small-8 w-col-tiny-8">
                    <a
                        onclick={(event : Event) => {
                            event.preventDefault()
                            m.route.set(homeUrl)
                        }}
                        href={homeUrl} class="header-logo w-inline-block" title="Catarse" >
                        <img src="/assets/catarse_bootstrap/logo_big.png" alt="Logo big" />
                    </a>
                    <If condition={!menuShort}>
                        <div id="menu-components">
                            <a href="https://crowdfunding.catarse.me/comece" class="w-hidden-small w-hidden-tiny header-link w-nav-link">
                                Comece seu projeto
                            </a>
                            <a onclick={goToExplore} href={`/${window.I18n.locale}/explore?ref=ctrse_header`} class="w-hidden-small w-hidden-tiny header-link w-nav-link">
                                Explore
                            </a>
                            <HeaderMenuSearch />
                        </div>
                    </If>
                </div>
                <div class="text-align-right w-col w-col-4 w-col-small-4 w-col-tiny-4">
                    <If condition={user && !!user.id}>
                        <UserProfileMenu user={user} />
                    </If>
                    <If condition={_.isEmpty(user) || user === undefined}>
                        <a href={`/${window.I18n.locale}/login?ref=ctrse_header`} class="w-nav-link header-link btn-edit u-right">
                            Login
                        </a>
                    </If>
                </div>
            </div>
            <If condition={!menuShort} >
                <div class="header-controls-mobile w-hidden-main w-hidden-medium">
                    <a onclick={goToStart} href={`/${window.I18n.locale}/start?ref=ctrse_header`} class="header-link w-nav-link">
                        Comece seu projeto
                    </a>
                    <a onclick={goToExplore} href={`/${window.I18n.locale}/explore?ref=ctrse_header`} class="header-link w-nav-link">
                        Explore
                    </a>
                </div>
            </If>
        </header>
    )
}
