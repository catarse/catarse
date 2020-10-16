import m from 'mithril';
import userVM from '../vms/user-vm';
import contributionVM from '../vms/contribution-vm';

const rewardReceiver = {
    oninit: function(vnode) {
        const toggleDelivery = (projectId, contribution) => {
            userVM.toggleDelivery(projectId, contribution).then(() => {
                const lastStatus = contribution.reward_sent_at ? 'delivered' : 'undelivered';
                contribution.delivery_status = contribution.delivery_status === 'received' ? lastStatus : 'received'; // so we don't have to reload the page
            });
        };

        vnode.state = {
            toggleDelivery
        };
    },
    view: function({state, attrs}) {
        const contribution = attrs.contribution;

        return contributionVM.canBeDelivered(contribution) ?
            m('.u-text-center.w-col.w-col-1', {
                onclick: () => state.toggleDelivery(contribution.project_id, contribution)
            }, [
                m('.fontsize-smallest',
                    m(`a.checkbox-big${contribution.delivery_status === 'received' ? '.checkbox--selected.fa.fa-check.fa-lg' : ''}`,
                        ''
                    )
                ),
                m('.fontcolor-secondary.fontsize-smallest.lineheight-looser',
                    'Recebi!'
                )
            ]) : m('');
    }
};

export default rewardReceiver;
