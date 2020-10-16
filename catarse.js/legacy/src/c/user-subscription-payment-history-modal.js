import m from 'mithril';
import dashboardSubscriptionCardDetailPaymentHistory from './dashboard-subscription-card-detail-payment-history';

const userSubscriptionPaymentHistoryModal = {
    view: function({attrs}) {
        const subscription = attrs.subscription,
            project = attrs.project;

        return m('div', [
            m('.modal-dialog-header',
                m('.fontsize-large.u-text-center', project.project_name)
            ),
            m('.u-margintop-30', 
                m(dashboardSubscriptionCardDetailPaymentHistory, { subscription })
            )
        ]);
    }
};

export default userSubscriptionPaymentHistoryModal;
