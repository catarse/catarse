import m from 'mithril'
import models from '../models'
import { commonNotification } from '../api'
import LoadMoreButton from '../c/load-more-btn';
import { useMemo, useState, withHooks } from 'mithril-hooks'
import { Pagination } from '../entities/pagination'
import { Loader } from '../shared/components/loader'
import { NotificationTemplate } from './admin-notifications';
import { HTMLRenderer } from '../shared/components/html-renderer';
import { NotificationData } from '../entities';
import FilterDropdown from '../c/filter-dropdown';
import FilterText from '../c/filter-text';
import './admin-notifications-list.css';

export const AdminNotificationsList = withHooks<AdminNotificationsListProps>(_AdminNotificationsList)

type AdminNotificationsListProps = {
    templates: NotificationTemplate[]
}

function _AdminNotificationsList({ templates }: AdminNotificationsListProps) {

    const { pagination, vm } = useMemo(() => loadUserNotifications(), [])
    const [subject, setSubject] = useState('')
    const [body, setBody] = useState('')
    const [variables, setVariables] = useState({})
    const [displayRendered, setDisplayRendered] = useState(false)

    const setupNotification = (notification: NotificationData) => {
        const template = templates.find(t => t.label === notification.label)
        setSubject(template.subject || template.default_subject)
        setBody(template.template || template.default_template)
        setVariables(notification.data.template_vars)
        setDisplayRendered(true)
    }

    const search = (e: Event) => {
        e?.preventDefault()
        pagination.firstPage(vm.parameters())
    }

    if (!pagination) return <Loader />

    return (
        <div class="section">
            <div class="w-container">
                <div class="w-form">
                    <div class="w-row">
                        <FilterText
                            label="ID do usuário"
                            vm={vm.user_external_id}
                            onchange={search}
                            wrapper_class='.u-marginbottom-20.w-col.w-col-4'
                            placeholder="ID do usuário"
                            onclick={search}
                        />
                        <FilterText
                            label="Nome"
                            vm={vm.user_name}
                            onchange={search}
                            wrapper_class='.u-marginbottom-20.w-col.w-col-4'
                            placeholder="Nome"
                            onclick={search}
                        />
                        <FilterText
                            label="Nome Público"
                            vm={vm.user_public_name}
                            onchange={search}
                            wrapper_class='.u-marginbottom-20.w-col.w-col-4'
                            placeholder="Nome Público"
                            onclick={search}
                        />

                    </div>
                    <div class="w-row">
                        <FilterText
                            label="Email"
                            vm={vm.user_email}
                            onchange={search}
                            wrapper_class='.u-marginbottom-20.w-col.w-col-6'
                            placeholder="Email"
                            onclick={search}
                        />
                        <FilterDropdown
                            label="Template"
                            onchange={search}
                            name="template"
                            vm={vm.label}
                            wrapper_class='.w-col.w-col-3'
                            options={[
                                {
                                    value: '',
                                    option: 'Todos'
                                },
                                ...templates.map(t => ({ value: t.label, option: t.label }))
                            ]}
                        />
                        <div class="w-col w-col-3">
                            <div class="w-row">
                                <button class="btn btn-medium btn-primary u-margintop-20 u-marginbottom-20" onclick={search}>
                                    Buscar
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="w-row">
                        <span class="w-col">Mostrando: {pagination.collection().length} de {pagination.total()}</span>
                    </div>
                </div>
            </div>
            <div class='w-container'>
                {displayRendered &&
                    <div>
                        <div class='card position-relative'>
                            <a onclick={() => setDisplayRendered(false)} class='fa fa-lg fa-close notification-close' style='cursor:pointer;'></a>
                        </div>
                        <div class='card'>
                            <h3>
                                <strong>Assunto: </strong>
                            </h3>
                            <HTMLRenderer html={subject} variables={variables} />
                            <h3>
                                <strong>Email: </strong>
                            </h3>
                            <HTMLRenderer html={body} variables={variables} />
                        </div>
                    </div>
                }
                <div class="u-marginbottom-60">
                    <div class="card card-secondary fontsize-smallest fontweight-semibold lineheight-tighter u-marginbottom-10">
                        <div class="w-row">
                            <div class="table-col w-col w-col-3">
                                <div>id</div>
                            </div>
                            <div class="table-col w-col w-col-3">
                                <div>label</div>
                            </div>
                            <div class="table-col w-col w-col-3">
                                <div>user_id</div>
                            </div>
                            <div class="table-col w-col w-col-3">
                                <div>created_at</div>
                            </div>
                        </div>
                    </div>
                    <div class="fontsize-smallest lineheight-tighter">
                        {pagination.collection() && pagination.collection().map(notification => {
                            return (
                                <div class='card w-row'>
                                    <div class="table-col w-col w-col-3">
                                        <a class='alt-link' style='cursor:pointer;' onclick={(e) => {
                                            e.preventDefault()
                                            setupNotification(notification)
                                        }}>{notification.id}</a>
                                    </div>
                                    <div class="table-col w-col w-col-3">{notification.label}</div>
                                    <div class="table-col w-col w-col-3">
                                        <strong>Nome público: </strong><span>{notification.user_public_name}</span><br/>
                                        <strong>Email: </strong><span>{notification.user_email}</span><br/>
                                        <strong>ID do usuário: </strong>
                                        <a class='alt-link' href={`/users/${notification.data.template_vars.user.external_id}`} target='_blank'>
                                            {notification.data.template_vars.user.external_id}
                                        </a><br/>
                                    </div>
                                    <div class="table-col w-col w-col-3">{notification.created_at}</div>
                                </div>
                            )
                        })}
                    </div>
                </div>
                <div class="section">
                    <div class="w-container">
                        <div class="u-marginbottom-60 w-row">
                            <LoadMoreButton collection={pagination} />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

function loadUserNotifications(): {
    pagination: Pagination<NotificationData>;
    vm: {
        user_external_id(value: string): void;
        label(value: string): void;
        user_name(value: string): void;
        user_public_name(value: string): void;
        user_email(value: string): void;
        parameters(): Object;
    }
} {
    const vm = commonNotification.filtersVM({
        user_external_id: 'eq',
        label: 'eq',
        user_name: 'like',
        user_public_name: 'like',
        user_email: 'like'
    })
    const pagination = commonNotification.paginationVM(
        models.userNotificationWithData,
        'created_at.desc',
        { Prefer: 'count=exact' }
    ) as Pagination<NotificationData>
    pagination.firstPage()
    return { pagination, vm };
}
