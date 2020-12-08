import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import moment from 'moment';
import h from '../h';
import { commonPayment } from '../api';
import models from '../models';

const I18nScope = _.partial(h.i18nScope, 'projects.subscription_fields');

export default class SubscriptionStatusIcon {
    oninit(vnode) {
        const statusClass = {
            active: 'fa-circle.text-success',
            started: 'fa-circle.text-waiting',
            inactive: 'fa-circle.text-error',
            canceled: 'fa-times-circle.text-error',
            canceling: 'fa-times-circle-o.text-error',
            deleted: 'fa-circle.text-error',
            error: 'fa-circle.text-error',
        },
            subscriptionTransition = prop(null);

        // get last subscription status transition from '/subscription_status_transitions' from this subscription
        if (vnode.attrs.subscription.id) {
            vnode.attrs.subscription.transition_date = vnode.attrs.subscription.created_at;

            const filterRowVM = commonPayment
                .filtersVM({
                    subscription_id: 'eq',
                    project_id: 'eq',
                })
                .order({
                    created_at: 'desc',
                })
                .subscription_id(vnode.attrs.subscription.id)
                .project_id(vnode.attrs.subscription.project_id);

            const lRew = commonPayment.loaderWithToken(models.subscriptionTransition.getRowOptions(filterRowVM.parameters()));
            lRew.load().then(data => {
                vnode.attrs.subscription.transition_date =
                    data && data.length > 0 && _.first(data).created_at ? _.first(data).created_at : vnode.attrs.subscription.created_at;
                h.redraw();
            });
        }

        vnode.state = {
            statusClass,
        };
    }

    view({ state, attrs }) {
        const subscription = attrs.subscription,
            statusClass = state.statusClass,
            statusToShowTransitionDate = ['started', 'canceling', 'canceled', 'inactive'],
            shouldShowTransitionDate = statusToShowTransitionDate.indexOf(subscription.status) >= 0;

        return m('span', [
            m('span.fontsize-smaller', [
                m(`span.fa.${statusClass[subscription.status] || 'Erro'}`, ' '),
                window.I18n.t(`status.${subscription.status}`, I18nScope()),
            ]),
            shouldShowTransitionDate ?
                m(
                    '.fontcolor-secondary.fontsize-mini.fontweight-semibold.lineheight-tightest',
                    `em ${h.momentify(subscription.transition_date, 'DD/MM/YYYY')}`
                )
                : '',
        ]);
    }
}
