import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import adminProject from './admin-project';
import adminContribution from './admin-contribution';
import adminContributionUser from './admin-contribution-user';
import paymentStatus from './payment-status';

const adminContributionItem = {
    oninit: function (vnode) {
        vnode.state = {
            itemBuilder: [{
                component: adminContributionUser,
                componentName: 'adminContributionUser',
                wrapperClass: '.w-col.w-col-4'
            }, {
                component: adminProject,
                componentName: 'adminProject',
                wrapperClass: '.w-col.w-col-4'
            }, {
                component: adminContribution,
                componentName: 'adminContribution',
                wrapperClass: '.w-col.w-col-2'
            }, {
                component: paymentStatus,
                componentName: 'paymentStatus',
                wrapperClass: '.w-col.w-col-2'
            }]
        };
    },
    view: function ({ state, attrs }) {
        return m(
            '.w-row',
            _.map(state.itemBuilder, panel => {
                
                return m(panel.wrapperClass, [
                    m(panel.component, {
                        item: attrs.item,
                        key: attrs.key
                    })
                ])
            })
        );
    }
};

export default adminContributionItem;
