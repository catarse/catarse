/**
 * window.c.AdminUserDetail component
 * Return action inputs to be used inside AdminList component.
 *
 * Example:
 * m.component(c.AdminList, {
 *     data: {},
 *     listDetail: c.AdminUserDetail
 * })
 */
import m from 'mithril';
import _ from 'underscore';
import models from '../models';
import adminExternalAction from './admin-external-action';
import userVM from '../vms/user-vm';
import adminResetPassword from './admin-reset-password';
import adminInputAction from './admin-input-action';
import adminNotificationHistory from './admin-notification-history';
import adminUserBalanceTransactionsList from './admin-user-balance-transactions-list';
import h from '../h';
import { catarse } from '../api';

const adminUserDetail = {
    oninit: function(vnode) {
        vnode.state = {
            actions: {
                reset: {
                    property: 'password',
                    callToAction: 'Redefinir',
                    innerLabel: 'Nova senha de Usuário:',
                    outerLabel: 'Redefinir senha',
                    placeholder: 'ex: 123mud@r',
                    model: models.user
                },
                ban: {
                    updateKey: 'id',
                    callToAction: 'Banir usuário',
                    innerLabel: 'Tem certeza que deseja banir o usuário?',
                    outerLabel: 'Banir usuário',
                    model: models.user
                },
                reactivate: {
                    property: 'deactivated_at',
                    updateKey: 'id',
                    callToAction: 'Reativar',
                    innerLabel: 'Tem certeza que deseja reativar esse usuário?',
                    successMessage: 'Usuário reativado com sucesso!',
                    errorMessage: 'O usuário não pôde ser reativado!',
                    outerLabel: 'Reativar usuário',
                    forceValue: null,
                    model: models.user
                }
            },
        };
    },
    view: function({state, attrs}) {
        const actions = state.actions,
            item = attrs.item,
            details = attrs.details,
            banUser = (builder, id) => _.extend({}, builder, {
                requestOptions: {
                    url: (`/users/${id}/ban`),
                    method: 'POST'
                }
            }),
            addOptions = (builder, id) => _.extend({}, builder, {
                requestOptions: {
                    url: (`/users/${id}/new_password`),
                    method: 'POST'
                }
            });

        return m('#admin-contribution-detail-box', [
            m('.divider.u-margintop-20.u-marginbottom-20'),
            m('.w-row.u-marginbottom-30', [
                m(adminResetPassword, {
                    data: addOptions(actions.reset, item.id),
                    item
                }),
                m(adminExternalAction, {
                    data: banUser(actions.ban, item.id),
                    item
                }),
                (item.deactivated_at) ?
                    m(adminInputAction, { data: actions.reactivate, item }) : ''
            ]),
            m('.w-row.card.card-terciary.u-radius', [
                m(adminNotificationHistory, {
                    user: item,
                    wrapperClass: '.w-col.w-col-4'
                }),
                m(adminUserBalanceTransactionsList, { user_id: item.id })
            ]),
        ]);
    }
};

export default adminUserDetail;
