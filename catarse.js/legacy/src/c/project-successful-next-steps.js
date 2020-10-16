import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import models from '../models';
import h from '../h';
import projectSuccessOnboard from './project-successful-onboard';
import projectSuccessOnboardProcessing from './project-successful-onboard-processing';
import projectSuccessOnboardEnabledWithdraw from './project-successful-onboard-enabled-withdraw';


const projectSuccessfulNextSteps = {

    oninit: function(vnode) {
        const 
            wishedState = 'transferred',
            userIdVM = catarse.filtersVM({user_id: 'eq', state: 'eq'}),
            lastBalanceTransfer = catarse.paginationVM(models.balanceTransfer, 'created_at.desc', { Prefer: 'count=exact' }),
            current_state = prop(vnode.attrs.project().state),
            isLoading = prop(true),
            successfulOnboards = () => {

                const onboardProjectAndCalculatedState = { project: vnode.attrs.project, current_state: current_state };
    
                if (isLoading()) {
                    return h.loader();
                }
                else {
                    switch(current_state()) {
                        case 'waiting_funds':
                            return m(projectSuccessOnboardProcessing, onboardProjectAndCalculatedState);
                        case 'successful_waiting_transfer':
                            return m(projectSuccessOnboardEnabledWithdraw, onboardProjectAndCalculatedState);
                        case 'successful':
                            return m(projectSuccessOnboard, onboardProjectAndCalculatedState);
                        default:
                            return h.loader();
                    }
                }
            };
        
        userIdVM.user_id(vnode.attrs.project().user_id).state(wishedState);
        lastBalanceTransfer
            .firstPage(userIdVM.parameters())
            .then((balanceTransfers) => {
                
                const 
                    lastBalanceTransferItem = _.first(balanceTransfers),
                    hasAtLeastOneTransfered = balanceTransfers.length > 0,
                    balanceCreatedAtDate = hasAtLeastOneTransfered ? new Date(lastBalanceTransferItem.transferred_at) : null,
                    projectExpiredAtDate = new Date(vnode.attrs.project().expires_at),
                    withdrawTransferredOccuredAfterProjectExpiredDate = hasAtLeastOneTransfered ? balanceCreatedAtDate.getTime() > projectExpiredAtDate.getTime() : false;

                if (withdrawTransferredOccuredAfterProjectExpiredDate) {
                    current_state('successful');
                }
                else {
                    if (vnode.attrs.project().state == 'successful')
                        current_state('successful_waiting_transfer');
                }

                isLoading(false);                
            });

        vnode.state = {
            successfulOnboards
        };
    },

    view: function({state, attrs}) {
        return state.successfulOnboards();        
    }
};

export default projectSuccessfulNextSteps;
