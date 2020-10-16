import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import h from '../h';
import models from '../models';
import adminInputAction from './admin-input-action';
import adminRadioAction from './admin-radio-action';
import adminExternalAction from './admin-external-action';
import adminTransaction from './admin-transaction';
import adminTransactionHistory from './admin-transaction-history';
import adminReward from './admin-reward';

const adminContributionDetail = {
    oninit: function(vnode) {
        let l;
        const loadReward = () => {
            const model = models.rewardDetail,
                reward_id = vnode.attrs.item.reward_id,
                opts = model.getRowOptions(h.idVM.id(reward_id).parameters()),
                reward = prop({});

            l = catarse.loaderWithToken(opts);

            if (reward_id) {
                l.load().then(_.compose(reward, _.first)).then(() => m.redraw());
            }

            return reward;
        };

        vnode.state = {
            reward: loadReward(),
            actions: {
                transfer: {
                    property: 'user_id',
                    updateKey: 'id',
                    callToAction: 'Transferir',
                    innerLabel: 'Id do novo apoiador:',
                    outerLabel: 'Transferir Apoio',
                    placeholder: 'ex: 129908',
                    successMessage: 'Apoio transferido com sucesso!',
                    errorMessage: 'O apoio não foi transferido!',
                    model: models.contributionDetail
                },
                reward: {
                    getKey: 'project_id',
                    updateKey: 'contribution_id',
                    selectKey: 'reward_id',
                    radios: 'rewards',
                    callToAction: 'Alterar Recompensa',
                    outerLabel: 'Recompensa',
                    getModel: models.rewardDetail,
                    updateModel: models.contributionDetail,
                    selectedItem: loadReward(),
                    addEmpty: { id: -1, minimum_value: 10, description: 'Sem recompensa' },
                    validate(rewards, newRewardID) {
                        const reward = _.findWhere(rewards, { id: newRewardID });
                        return (vnode.attrs.item.value >= reward.minimum_value) ? undefined : 'Valor mínimo da recompensa é maior do que o valor da contribuição.';
                    }
                },
                refund: {
                    updateKey: 'id',
                    callToAction: 'Reembolso direto',
                    innerLabel: 'Tem certeza que deseja reembolsar esse apoio?',
                    outerLabel: 'Reembolsar Apoio',
                    model: models.contributionDetail
                },
                remove: {
                    property: 'state',
                    updateKey: 'id',
                    callToAction: 'Apagar',
                    innerLabel: 'Tem certeza que deseja apagar esse apoio?',
                    outerLabel: 'Apagar Apoio',
                    forceValue: 'deleted',
                    successMessage: 'Apoio removido com sucesso!',
                    errorMessage: 'O apoio não foi removido!',
                    model: models.contributionDetail
                }
            },
            l
        };
    },
    view: function({state, attrs}) {
        const actions = state.actions,
            item = attrs.item,
            reward = state.reward,
            addOptions = (builder, id) => _.extend({}, builder, {
                requestOptions: {
                    url: (`/admin/contributions/${id}/gateway_refund`),
                    method: 'PUT'
                }
            });

        return m('#admin-contribution-detail-box', [
            m('.divider.u-margintop-20.u-marginbottom-20'),
            m('.w-row.u-marginbottom-30', [
                m(adminInputAction, {
                    data: actions.transfer,
                    item
                }),
                (
                    state.l() ? 
                        h.loader() 
                    :
                    m(adminRadioAction, {
                        data: actions.reward,
                        item: reward,
                        getKeyValue: item.project_id,
                        updateKeyValue: item.contribution_id
                    })
                ),
                m(adminExternalAction, {
                    data: addOptions(actions.refund, item.id),
                    item
                }),
                m(adminInputAction, {
                    data: actions.remove,
                    item
                })
            ]),
            m('.w-row.card.card-terciary.u-radius', [
                m(adminTransaction, {
                    contribution: item
                }),
                m(adminTransactionHistory, {
                    contribution: item
                }),
                (
                    state.l() ? 
                        h.loader()
                    :
                        m(adminReward, {
                            reward,
                            contribution: item,
                            key: item.key
                        })
                )
            ])
        ]);
    }
};

export default adminContributionDetail;
