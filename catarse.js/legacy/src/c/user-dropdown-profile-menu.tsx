import m from 'mithril'
import { withHooks } from 'mithril-hooks'
import { ThisWindow, UserDetails } from '../entities'
import { CurrencyFormat } from '../shared/components/currency-format'
import { AdminMenuLinks } from './admin-menu-links'
import ConnectFacebook from './connect-facebook';

declare var window : ThisWindow

export const UserDropdownProfileMenu = withHooks<UserDropdownProfileMenuProps>(_UserDropdownProfileMenu)

type UserDropdownProfileMenuProps = {
    balance: number
    user: UserDetails
}

type MenuItem = {
    label: m.Children
    url: string
}

function _UserDropdownProfileMenu({ balance, user } : UserDropdownProfileMenuProps) {

    const {
        historyMenuItems,
        settingsMenuItems
    } = createMenusItems(user, balance)

    return (
        <nav style="display:block;" class="w-dropdown-list dropdown-list user-menu w--open" id="user-menu-dropdown">
            <div class="w-row">
                <div class="w-col w-col-12">
                    <div class="fontweight-semibold fontsize-smaller u-marginbottom-10">
                        Meu histórico
                    </div>
                    <ul class="w-list-unstyled u-marginbottom-20">
                        {historyMenuItems.map(item => (
                            <UserMenuItemLink item={item} />
                        ))}
                    </ul>
                    <div class="fontweight-semibold fontsize-smaller u-marginbottom-10">
                        Configurações
                    </div>
                    <ul class="w-list-unstyled u-marginbottom-20">
                        {settingsMenuItems.map(item => (
                            <UserMenuItemLink item={item} />
                        ))}
                    </ul>
                    <div class="divider u-marginbottom-20"></div>
                    {user.is_admin_role && <AdminMenuLinks />}
                    <div class="fontsize-mini">
                        Seu e-mail de cadastro é:
                    </div>
                    <div class="fontsize-smallest u-marginbottom-20">
                        <span class="fontweight-semibold">
                            {user.email}
                        </span>
                        <a href={`/${window.I18n.locale}/users/${user.id}/edit#about_me`} class="alt-link">
                            &nbsp;alterar e-mail
                        </a>
                    </div>
                    <div className="divider u-marginbottom-20"></div>
                    <a href={`/${window.I18n.locale}/logout`} class="alt-link">
                        Sair
                    </a>
                </div>
            </div>
        </nav>
    )
}

function createMenusItems(user: { id: number }, balance: number) {
    const historyMenuItems: MenuItem[] = [
        {
            label: (
                <span>
                    Saldo {
                        balance ?
                            <span class='fontcolor-secondary'>
                                <CurrencyFormat value={balance} />
                            </span>
                            :
                            ''
                        }
                </span>
            ),
            url: `/users/${user.id}/edit#balance`
        },
        {
            label: 'Histórico de apoio',
            url: `/users/${user.id}/edit#contributions`
        },
        {
            label: 'Projetos criados',
            url: `/users/${user.id}/edit#projects`
        }
    ]

    const settingsMenuItems : MenuItem[] = [
        {
            label: 'Encontre amigos',
            url: '/connect-facebook/'
        },
        {
            label: 'Perfil público',
            url: `/users/${user.id}/edit#about_me`
        },
        {
            label: 'Notificações',
            url: `/users/${user.id}/edit#notifications`
        },
        {
            label: 'Dados cadastrais',
            url: `/users/${user.id}/edit#settings`
        }
    ]

    return {
        historyMenuItems,
        settingsMenuItems
    }
}

const UserMenuItemLink = withHooks<{ item : MenuItem }>(_UserMenuItemLink)

function _UserMenuItemLink({ item: { label, url }} : { item : MenuItem }) {
    return (
        use_connect_facebook(label) ?
        <ConnectFacebook
            label={'Encontre amigos'}
            linkClass={'a.alt-link.fontsize-smaller'}
            buttonClass={'input.alt-link.fontsize-smaller'}
            styleInput={'border: unset; background-color: unset; padding-left: 0'}
        />
        :
        <li class="lineheight-looser">
            <a href={`/${window.I18n.locale}${url}`} class="alt-link fontsize-smaller">
                {label}
            </a>
        </li>
    )
}

function use_connect_facebook(label) {
    if (label == 'Encontre amigos') {
        return true
    }
    false
}
