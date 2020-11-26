import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import {
    catarse,
    commonAnalytics
} from '../api';
import h from '../h';
import models from '../models';
import adminInputAction from './admin-input-action';
import adminRadioAction from './admin-radio-action';
import adminExternalAction from './admin-external-action';
import projectVM from '../vms/project-vm';

const adminProjectDetail = {
    oninit: function(vnode) {
        let bankl;
        const currentItem = prop(vnode.attrs.item);
        const project_id = vnode.attrs.item.project_id;
        const loadBank = () => {
            const model = models.projectAccount,
                opts = model.getRowOptions(h.idVM.id(project_id).parameters()),
                project = prop({});

            bankl = catarse.loaderWithToken(opts);

            if (project_id) {
                bankl.load().then(_.compose(project, _.first));
            }

            return project;
        };
        let l;
        const loadUser = () => {
            const model = models.userDetail,
                user_id = vnode.attrs.item.user_id,
                opts = model.getRowOptions(h.idVM.id(user_id).parameters()),
                user = prop({});

            l = catarse.loaderWithToken(opts);

            if (user_id) {
                l.load().then(_.compose(user, _.first));
            }

            return user;
        };

        const changeUserAction = {
            toggler: h.toggleProp(false, true),
            submit: newValue => () => {
                changeUserAction.complete(false);
                projectVM
                    .updateProject(project_id, { user_id: newValue })
                    .then(() => {
                        changeUserAction.complete(true);
                        changeUserAction.success(true);
                        changeUserAction.error(false);
                    })
                    .catch(() => {
                        changeUserAction.complete(true);
                        changeUserAction.success(true);
                        changeUserAction.error(true);
                    });
                return false;
            },
            complete: prop(false),
            error: prop(false),
            success: prop(false),
            newValue: prop('')
        };

        const contributionReport = {
            toggler: h.toggleProp(false, true)
        };

        const actionUnload = action => () => {
            action.complete(false);
            action.error(false);
            action.success(false);
            action.newValue('');
        };

        const projectSubscriberInfo = prop();
        const projectRevert = {
            toggler: h.toggleProp(false, true),
            loading: h.toggleProp(false, true),
            submit: () => {
                projectRevert.loading.toggle();
                m.redraw();
                m.request({
                    method: 'PUT',
                    config: h.setCsrfToken,
                    url: `/admin/projects/${project_id}/revert_or_finish`
                }).then((data) => {
                    console.log(data);
                    catarse.loaderWithToken(
                        models.adminProject.getRowOptions({project_id: `eq.${project_id}`})
                    ).load().then((response) => {
                        currentItem(response);
                        projectRevert.loading.toggle();
                        projectRevert.toggler.toggle();
                    })
                });
            }
        };

        if (vnode.attrs.item.mode === 'sub') {
            commonAnalytics.loaderWithToken(models.projectSubscribersInfo.postOptions({
                id: vnode.attrs.item.common_id
            })).load().then(projectSubscriberInfo);
        }

        vnode.state = {
            user: loadUser(),
            bankAccount: loadBank(),
            subscriberInfo: projectSubscriberInfo,
            actions: {
                changeUserAction,
                projectRevert
            },
            currentItem,
            actionUnload
        };
    },
    view: function({state, attrs}) {
        const actions = state.actions,
            item = state.currentItem(),
            user = state.user(),
            bankAccount = state.bankAccount(),
            userAddress = user.address || {},
            subscriberInfo = state.subscriberInfo(),
            totalSubscriptions = subscriberInfo ? subscriberInfo.total_subscriptions : 0;

        return m('#admin-contribution-detail-box', [
            m('.divider.u-margintop-20.u-marginbottom-20'),
            m('.w-row.u-marginbottom-30', [
                m('.w-col.w-col-2', [
                    m('button.btn.btn-small.btn-terciary', {
                        onclick: state.actions.changeUserAction.toggler.toggle
                    }, 'Trocar realizador'),
                    (state.actions.changeUserAction.toggler() ? 
                        m('.dropdown-list.card.u-radius.dropdown-list-medium.zindex-10', {
                            oncreate: state.actionUnload(state.actions.changeUserAction)
                        }, [
                            m('form.w-form', {
                                onsubmit: state.actions.changeUserAction.submit
                            }, (!state.actions.changeUserAction.complete()) ? [
                                m('label', 'Id do novo realizador:'),
                                m('input.w-input.text-field[type="tel"][placeholder="ex: 239049"]', {
                                    onchange: m.withAttr('value', state.actions.changeUserAction.newValue),
                                    value: state.actions.changeUserAction.newValue()
                                }),
                                m('input.w-button.btn.btn-small[type="submit"][value="Transferir"]', {
                                    onclick: state.actions.changeUserAction.submit(state.actions.changeUserAction.newValue())
                                })
                            ] : (!state.actions.changeUserAction.error()) ? [
                                m('.w-form-done[style="display:block;"]', [
                                    m('p', 'Usuário transferido com sucesso')
                                ])
                            ] : [
                                m('.w-form-error[style="display:block;"]', [
                                    m('p', 'Houve um problema na requisição. Verifique se o usuário que vai receber o projeto possui dados válidos.')
                                ])
                            ])
                        ]) : '')
                ]),
                m('.w-col.w-col-2', [
                    (item.mode === 'sub' ?
                        m('a.btn.btn-small.btn-terciary', { href: `/projects/${item.project_id}/subscriptions_report` }, 'Base de assinantes')
                        : m('a.btn.btn-small.btn-terciary', { href: `/projects/${item.project_id}/contributions_report` }, 'Relatório de apoios'))
                ]),
                (item.mode === 'sub' && item.state === 'online' ?
                    m('.w-col.w-col-3', [
                        m('button.btn.btn-small.btn-terciary', {
                            onclick: state.actions.projectRevert.toggler.toggle
                        }, (totalSubscriptions > 0 ? 'Encerrar projeto' : 'Virar projeto para Draft')),
                        (state.actions.projectRevert.toggler() ? 
                            (state.actions.projectRevert.loading() ? h.loader()
                                : m('.dropdown-list.card.u-radius.dropdown-list-medium.zindex-10', [
                                    m('form.w-form', {
                                        onsubmit: state.actions.projectRevert.submit
                                    }, [
                                        m('label', (totalSubscriptions > 0 ? 'Ao encerrar esse projeto, ele será convertido para o status FINALIZADO (Flex) e suas assinaturas serão transformadas em CANCELADAS. Tem certeza que deseja encerrar esse projeto?' : 'Tem certeza que deseja transformar esse projeto em Draft?')),
                                        m('input.w-button.btn.btn-small[type="submit"]', {
                                            value: (totalSubscriptions > 0 ? 'Encerrar projeto' : 'Virar projeto para Draft' )
                                        })
                                    ])
                                ])) : '')
                    ]) : '')
            ]),
            m('.w-row.card.card-terciary.u-radius', [
                m('.w-col.w-col-4', [
                    m('.fontsize-smaller.fontweight-semibold.lineheight-tighter.u-marginbottom-20',
                        'Detalhes do projeto'
                    ),
                    m('.fontsize-smallest.fontweight-semibold.u-marginbottom-20',
                        `catarse.me/${item.permalink}`
                    ),
                    m('.fontsize-smallest.lineheight-looser.u-marginbottom-20', [
                        m('span.fontweight-semibold',
                            'Meta:'
                        ),
                        ` R$ ${h.formatNumber(item.goal, 2, 3)}\ `,
                        m('br'),
                        m('span.fontweight-semibold',
                            'Alcançado:'
                        ),
                        ` R$ ${h.formatNumber(item.pledged, 2, 3)}\ `
                    ]),
                    m('.fontsize-smallest.lineheight-looser', [
                        m('span.fontweight-semibold',
                            'Início: '
                        ),
                        h.momentify(item.project_online_date, 'DD/MM/YYYY, HH:mm'),
                        m('br'),
                        m('span.fontweight-semibold',
                            'Término: '
                        ),
                        h.momentify(item.project_expires_at, 'DD/MM/YYYY, HH:mm'),
                        m('br'),
                        m('span.fontweight-semibold',
                            'Últ. atualização: '
                        ),
                        h.momentify(item.updated_at, 'DD/MM/YYYY, HH:mm'),
                        m('br'),
                        m('span.fontweight-semibold',
                            'Novidades: '
                        ),
                        item.posts_count,
                        m('br'),
                        m('span.fontweight-semibold',
                            'Últ. novidade: '
                        ),
                        h.momentify(item.last_post, 'DD/MM/YYYY, HH:mm')
                    ])
                ]),
                m('.w-col.w-col-4', [
                    m('.fontsize-smaller.fontweight-semibold.lineheight-tighter.u-marginbottom-20',
                        'Dados bancários'
                    ),
                    m('.fontsize-smallest.lineheight-looser', [
                        m('span.fontweight-semibold',
                            'Banco: '
                        ),
                        bankAccount.bank_name,
                        m('br'),
                        m('span.fontweight-semibold',
                            'Agencia: '
                        ),
                        `${bankAccount.agency}-${bankAccount.agency_digit}`,
                        m('br'),
                        m('span.fontweight-semibold',
                            'Conta: '
                        ),
                        `${bankAccount.account}-${bankAccount.account_digit}`,
                        m('br'),
                        bankAccount.account_type,
                        m('br'),
                        m('span.fontweight-semibold',
                            'Nome: '
                        ),
                        bankAccount.owner_name,
                        m('br'),
                        m('span.fontweight-semibold',
                            'CPF: '
                        ),
                        bankAccount.owner_document
                    ])
                ]),
                m('.w-col.w-col-4', [
                    m('.fontsize-smaller.fontweight-semibold.lineheight-tighter.u-marginbottom-20',
                        'Detalhes do realizador'
                    ),
                    m('.fontsize-smallest.lineheight-looser.u-marginbottom-20', [
                        m('span.fontweight-semibold',
                            'Nome: '
                        ),
                        user.name,
                        m('br'),
                        m('span.fontweight-semibold',
                            'CPF: '
                        ),
                        user.owner_document,
                        m('br'),
                        m('span.fontweight-semibold',
                            'Inscrição estadual: '
                        ),
                        user.state_inscription,
                        m('br'),
                        m('span.fontweight-semibold',
                            'Email: '
                        ),
                        user.email,
                        m('br'),
                        m('span.fontweight-semibold',
                            'Endereço: '
                        ),
                        m.trust('&nbsp;'),
                        ` ${userAddress.address_street}, ${userAddress.address_number} ${userAddress.address_complement} - ${userAddress.address_city} - ${userAddress.address_state} ${userAddress.address_zip_code}`,
                        m('br'),
                        m('span.fontweight-semibold',
                            'Telefone:'
                        ),
                        userAddress.phone_number
                    ]),
                    m('.fontsize-smallest.lineheight-looser', [
                        `${user.total_published_projects} projetos criados `,
                        m('br'),
                        m.trust('&nbsp;'),
                        m('br')
                    ])
                ])
            ])
        ]);
    }
};

export default adminProjectDetail;
