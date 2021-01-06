import { withHooks } from 'mithril-hooks'
import { ThisWindow } from '../entities'

declare var window : ThisWindow

export const AdminMenuLinks = withHooks(_AdminMenuLinks)

function _AdminMenuLinks() {
    return (
        <>
            <div class="fontweight-semibold fontsize-smaller u-marginbottom-10">
                Admin
            </div>
            <ul class="w-list-unstyled u-marginbottom-20">
                {ITEMS.map(item => (
                    <AdminMenuListItem item={item} />
                ))}
            </ul>
        </>
    )
}

type AdminMenuListItemProps = {
    item: MenuItem
}

type MenuItem = {
    label: string
    url: string
}

const AdminMenuListItem = withHooks<AdminMenuListItemProps>(_AdminMenuListItem)

function _AdminMenuListItem({ item: { label, url } } : AdminMenuListItemProps) {
    return (
        <li class="lineheight-looser">
            <a href={`/${window.I18n.locale}${url}`} class="alt-link fontsize-smaller">
                {label}
            </a>
        </li>
    )
}



const ITEMS : MenuItem[] = [
    {
        label: 'Banners',
        url: '/new-admin#/home-banners'
    },
    {
        label: 'Usuários',
        url: '/new-admin#/users'
    },
    {
        label: 'Apoios',
        url: '/new-admin'
    },
    {
        label: 'Saques',
        url: '/new-admin#/balance-transfers'
    },
    {
        label: 'Rel. Financeiros',
        url: '/admin/financials'
    },
    {
        label: 'Admin projetos',
        url: '/new-admin#/projects'
    },
    {
        label: 'Admin assinaturas',
        url: '/new-admin#/subscriptions'
    },
    {
        label: 'Admin notificações',
        url: '/new-admin#/notifications'
    },
    {
        label: 'Dataclips',
        url: '/dbhero'
    }
]
