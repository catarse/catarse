import { catarse, commonProject } from '../api'
import _ from 'underscore'
import m from 'mithril'
import prop from 'mithril/stream'
import models from '../models'
import h from '../h'
import { State } from '../entities'

const error = prop(''),
    rewards = prop([]),
    states = h.RedrawStream<State[]>([]),
    fees = prop([]),
    noReward = {
        id: null,
        description: '',
        shipping_options: null,
        minimum_value: 10,
    },
    contributionValue = prop(noReward.minimum_value),
    selectedReward = prop(),
    vm = catarse.filtersVM({
        project_id: 'eq',
    });

const rewardsLoader = projectId => {
    vm.project_id(projectId);

    return catarse.loaderWithToken(models.rewardDetail.getPageOptions(vm.parameters()));
};

const rewardLoader = rewardId => {
    const rewardvm = catarse.filtersVM({
        id: 'eq',
    });
    rewardvm.id(rewardId);

    return catarse.loaderWithToken(models.rewardDetail.getPageOptions(rewardvm.parameters()));
};

const fetchRewards = projectId =>
    rewardsLoader(projectId)
        .load()
        .then(rewardsData => {
            rewards(rewardsData);
            h.redraw();
            return rewardsData;
        });

const fetchCommonRewards = projectId => {
    vm.project_id(projectId);
    const l = commonProject.loaderWithToken(models.projectReward.getPageOptions(vm.parameters()));
    return l.load().then(rewardsData => {
        rewards(rewardsData);
        h.redraw();
        return rewardsData;
    });
};

const getFees = reward => {
    const feesFilter = catarse.filtersVM({
        reward_id: 'eq',
    });

    feesFilter.reward_id(reward.id);
    const feesLoader = catarse.loader(models.shippingFee.getPageOptions(feesFilter.parameters()));
    return feesLoader.load();
};

const getSelectedReward = () => {
    const root = document.getElementById('application'),
        data = root && root.getAttribute('data-contribution');

    if (data) {
        const contribution = JSON.parse(data);

        selectedReward(contribution.reward);
        h.redraw();

        return selectedReward;
    }

    return false;
};

const selectReward = reward => () => {
    if (selectedReward() !== reward) {
        error('');
        selectedReward(reward);
        if (reward.id) {
            contributionValue(h.applyMonetaryMask(`${reward.minimum_value},00`));
        } else {
            // no reward
            if (contributionValue() === '10,00' || !contributionValue()) contributionValue(h.applyMonetaryMask('$10,00'));
        }

        if (reward.id) {
            getFees(reward).then(feesData => {
                fees(feesData);
                h.redraw();
            });
        }
    }
};

const applyMask = _.compose(
    contributionValue,
    h.applyMonetaryMask
);

const statesLoader = catarse.loader(models.state.getPageOptions())
const getStates = () => {
    loadStates()
    return states
}

let isLoadingStates = false
const loadStates = async () => {
    try {
        const loadedStates = states()
        if (loadedStates?.length === 0 && !isLoadingStates) {
            isLoadingStates = true
            states(await statesLoader.load())
            isLoadingStates = false
        }
    } catch(error) {
        states([])
        isLoadingStates = false
    }
}

const locationOptions = (reward, destination) => {
    const options = prop([]),
        mapStates = _.map(states(), state => {
            let fee;
            const feeState = _.findWhere(fees(), {
                destination: state.acronym,
            });
            const feeOthers = _.findWhere(fees(), {
                destination: 'others',
            });
            if (feeState) {
                fee = feeState.value;
            } else if (feeOthers) {
                fee = feeOthers.value;
            }

            return {
                name: state.name,
                value: state.acronym,
                fee,
            };
        });
    if (reward.shipping_options === 'national') {
        options(mapStates);
    } else if (reward.shipping_options === 'international') {
        let fee;
        const feeInternational = _.findWhere(fees(), {
            destination: 'international',
        });
        if (feeInternational) {
            fee = feeInternational.value;
        }
        options(
            _.union(
                [
                    {
                        value: 'international',
                        name: 'Outside Brazil',
                        fee,
                    },
                ],
                mapStates
            )
        );
    }

    options(
        _.union(
            [
                {
                    value: '',
                    name: 'Selecione Opção',
                    fee: 0,
                },
            ],
            options()
        )
    );

    return options();
};

const shippingFeeById = feeId =>
    _.findWhere(fees(), {
        id: feeId,
    });

const getOtherNationalStates = () =>
    _.reject(
        states(),
        state =>
            !_.isUndefined(
                _.findWhere(fees(), {
                    destination: state.acronym,
                })
            )
    );

const feeDestination = (reward, feeId) => {
    const fee = shippingFeeById(feeId) || {};
    const feeState = _.findWhere(states(), {
        acronym: fee.destination,
    });

    if (feeState) {
        return feeState.acronym;
    } else if (reward.shipping_options === 'national' && fee.destination === 'others') {
        return _.pluck(getOtherNationalStates(), 'acronym').join(', ');
    }

    return fee.destination;
};

const shippingFeeForCurrentReward = selectedDestination => {
    let currentFee = _.findWhere(fees(), {
        destination: selectedDestination(),
    });

    if (
        !currentFee &&
        _.findWhere(states(), {
            acronym: selectedDestination(),
        })
    ) {
        currentFee = _.findWhere(fees(), {
            destination: 'others',
        });
    }

    return currentFee;
};

const createReward = (projectId, rewardData) =>
    m.request({
        method: 'POST',
        url: `/projects/${projectId}/rewards.json`,
        data: {
            reward: rewardData,
        },
        config: h.setCsrfToken,
    });

const updateReward = (projectId, rewardId, rewardData) =>
    m.request({
        method: 'PATCH',
        url: `/projects/${projectId}/rewards/${rewardId}.json`,
        data: {
            reward: rewardData,
        },
        config: h.setCsrfToken,
    });

const uploadImage = (projectId, rewardId, rewardImageFile) => {
    const formData = new FormData();
    formData.append('uploaded_image', rewardImageFile);
    return m.request({
        method: 'POST',
        url: `/projects/${projectId}/rewards/${rewardId}/upload_image`,
        data: formData,
        config: h.setCsrfToken,
        serialize(data) {
            return data;
        },
    });
};

const deleteImage = (projectId, rewardId) => {
    return m.request({
        method: 'DELETE',
        url: `/projects/${projectId}/rewards/${rewardId}/delete_image`,
        config: h.setCsrfToken,
    });
};

const canEdit = (reward, projectState, user) =>
    (user || {}).is_admin ||
    (projectState === 'draft' ||
        (projectState === 'online' && reward.paid_count() <= 0 && (_.isFunction(reward.waiting_payment_count) ? reward.waiting_payment_count() <= 0 : true)));

const canAdd = (projectState, user) => (user || {}).is_admin || projectState === 'draft' || projectState === 'online';

const hasShippingOptions = reward => !(_.isNull(reward.shipping_options) || reward.shipping_options === 'free' || reward.shipping_options === 'presential');

const rewardVM = {
    canEdit,
    canAdd,
    error,
    getStates,
    getFees,
    rewardLoader,
    fees,
    rewards,
    applyMask,
    noReward,
    fetchRewards,
    fetchCommonRewards,
    selectReward,
    getSelectedReward,
    selectedReward,
    contributionValue,
    updateReward,
    createReward,
    rewardsLoader,
    locationOptions,
    shippingFeeForCurrentReward,
    shippingFeeById,
    statesLoader,
    feeDestination,
    getValue: contributionValue,
    setValue: contributionValue,
    hasShippingOptions,
    uploadImage,
    deleteImage,
};

export default rewardVM;
