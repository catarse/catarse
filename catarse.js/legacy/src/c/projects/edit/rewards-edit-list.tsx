import m from 'mithril'
import moment from 'moment'
import _ from 'underscore'
import h from '../../../h'
import { RewardDetails } from '../../../@types/reward-details'
import { RewardDetailsStream, ToggleStream, StreamType } from '../../../@types/reward-details-stream'
import rewardVM from '../../../vms/reward-vm'
import dashboardRewardCard from '../../dashboard-reward-card'
import editRewardCard from '../../edit-reward-card'
import userVM from '../../../vms/user-vm'
import { ProjectDetails } from '../../../@types/project-details'
import { RewardsEditListCard } from './rewards-edit-list-card'

type ExtendedWindow = {
    $(...params: any[]): any
    I18n: {
        locale: string
        t(path: string, ...params: any[])
    }
}

const { $, I18n } = window as any as ExtendedWindow;
const jQuery = $
const I18nScope = _.partial(h.i18nScope, 'projects.reward_fields');
const prop = h.RedrawStream as <T>(data?: T, onUpdate?: (data: T) => void) => (newData?: T) => T

export type RewardsEditListAttrs = {
    class: string
    project_id: number
    user_id: number
    project: StreamType<ProjectDetails>
    error: StreamType<boolean>
    errors: StreamType<string>
    showSuccess: StreamType<boolean>
    loading: StreamType<boolean>
}

export type RewardsEditListState = {
    rewards: StreamType<StreamType<RewardDetailsStream>[]>
    newReward(): RewardDetailsStream
    user: StreamType<{}>
    setSorting(localVnode: m.VnodeDOM<{}, {}>): void
    showImageToUpload(reward: any, imageFileToUpload: any, imageInputElementFile: any): void
    deleteImage(reward: any, projectId: any, rewardId: any): Promise<any>
    uploadImage(reward: any, imageFileToUpload: any, projectId: any, rewardId: any): Promise<any>
}

export class RewardsEditList implements m.Component {

    oninit({ attrs, state }: m.Vnode<RewardsEditListAttrs, RewardsEditListState>) {
        const rewards = prop<StreamType<RewardDetailsStream>[]>([])
        const loading = attrs.loading
        const error = attrs.error
        const errors = attrs.errors
        const showSuccess = attrs.showSuccess
        function newReward(): RewardDetailsStream {
            return {
                id: prop(null),
                minimum_value: prop(null),
                title: prop(''),
                shipping_options: prop('free'),
                edit: h.toggleProp(true, false) as any as ToggleStream<boolean>,
                deliver_at: prop(moment().date(1).format()),
                description: prop(''),
                paid_count: prop(0),
                waiting_payment_count: prop(0),
                limited: h.toggleProp(false, true) as any as ToggleStream<boolean>,
                maximum_contributions: prop(null),
                run_out: h.toggleProp(false, true) as any as ToggleStream<boolean>,
                newReward: true,
                uploaded_image: prop(null),
                row_order: prop(999999999 + (rewards().length * 20)) // we need large and spaced apart numbers
            };
        }

        const updateRewardSortPosition = (rewardId, position) => m.request({
            method: 'POST',
            url: `/${I18n.locale}/projects/${attrs.project_id}/rewards/${rewardId}/sort?reward[row_order_position]=${position}`,
            config: (xhr) => {
                if (h.authenticityToken()) {
                    xhr.setRequestHeader('X-CSRF-Token', h.authenticityToken());
                    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
                }
            }
        });

        function setSorting(localVnode: m.VnodeDOM) {
            if (jQuery) {
                jQuery(localVnode.dom).sortable({
                    update(event, ui) {
                        const rewardId = ui.item[0].id
                        updateRewardSortPosition(rewardId, ui.item.index())
                    }
                })
            }
        }

        async function loadRewards() {

            await rewardVM.fetchRewards(attrs.project_id)

            rewards([]);

            for (const reward of rewardVM.rewards()) {

                const limited = reward.maximum_contributions !== null && !reward.run_out;
                const rewardDataStreams: RewardDetailsStream = {
                    id: prop(reward.id),
                    deliver_at: prop(reward.deliver_at),
                    description: prop(reward.description),
                    run_out: h.toggleProp(reward.run_out, !reward.run_out) as any as ToggleStream<boolean>,
                    maximum_contributions: prop(reward.maximum_contributions),
                    minimum_value: prop(reward.minimum_value),
                    edit: h.toggleProp(false, true) as any as ToggleStream<boolean>,
                    limited: h.toggleProp(limited, !limited) as any as ToggleStream<boolean>,
                    paid_count: prop(reward.paid_count),
                    row_order: prop(reward.row_order),
                    shipping_options: prop(reward.shipping_options),
                    title: prop(reward.title),
                    uploaded_image: prop(reward.uploaded_image),
                    waiting_payment_count: prop(reward.waiting_payment_count),
                    newReward: false,
                }

                const rewardDataStreamProp = prop<RewardDetailsStream>(rewardDataStreams)
                rewards(rewards().concat([rewardDataStreamProp]));
            }

            if (rewardVM.rewards().length === 0) {
                rewards([prop(newReward())]);
            }

            h.redraw();
        }

        const uploadImage = (reward, imageFileToUpload, projectId, rewardId) => {
            if (imageFileToUpload()) {
                return rewardVM
                    .uploadImage(projectId, rewardId, imageFileToUpload())
                    .then(r => {
                        if (r) {
                            reward.uploaded_image(r.uploaded_image);
                        }
                        return r;
                    })
                    .catch(err => {
                        error(true);
                        errors('Erro ao fazer upload da imagem da recompensa. Favor tentar novamente.');
                    });
            } else {
                return Promise.resolve();
            }
        };

        const deleteImage = (reward, projectId, rewardId) => {
            return rewardVM.deleteImage(projectId, rewardId)
                .then(r => {
                    if (r) {
                        reward.uploaded_image(r.uploaded_image);
                    }
                    return r;
                })
                .catch(err => {
                    error(true);
                    errors('Erro ao deletar a imagem da recompensa. Favor tentar novamente.');
                });
        };

        const showImageToUpload = (reward, imageFileToUpload, imageInputElementFile) => {
            const reader = new FileReader();
            reader.onload = function () {
                imageFileToUpload(imageInputElementFile);
                var dataURL = reader.result;
                reward.uploaded_image(dataURL);
                m.redraw();
            };
            reader.readAsDataURL(imageInputElementFile);
        };

        loadRewards()

        state.rewards = rewards
        state.user = userVM.fetchUser(attrs.user_id) as StreamType<{}>
        state.newReward = newReward
        state.setSorting = setSorting
        state.showImageToUpload = showImageToUpload
        state.deleteImage = deleteImage
        state.uploadImage = uploadImage
    }

    view({ attrs, state }: m.Vnode<RewardsEditListAttrs, RewardsEditListState>) {

        const loading = attrs.loading
        const error = attrs.error
        const errors = attrs.errors
        const showSuccess = attrs.showSuccess
        const project = attrs.project
        const showImageToUpload = state.showImageToUpload
        const deleteImage = state.deleteImage
        const uploadImage = state.uploadImage
        const project_id = attrs.project_id
        const sortedRewards = _.sortBy(state.rewards(), reward => Number(reward().row_order()))
        const hasRewards = state.rewards().length > 0
        const shouldShowAddRewardButton = rewardVM.canAdd(project().state, state.user())

        return (
            <>
                <div class='w-form'>
                    {
                        hasRewards &&
                        <div oncreate={state.setSorting} id='rewards' class='ui-sortable'>
                            {sortedRewards.map((reward, index) =>
                                <RewardsEditListCard
                                    reward={reward}
                                    index={index}
                                    project={project}
                                    error={error}
                                    errors={errors}
                                    user={state.user}
                                    showSuccess={showSuccess}
                                    loading={loading}
                                    showImageToUpload={showImageToUpload}
                                    deleteImage={deleteImage}
                                    uploadImage={uploadImage}
                                    class={attrs.class}
                                    project_id={project_id}
                                />
                            )}
                        </div>
                    }
                </div>
                <AddRewardButton 
                    shouldDisplayButton={shouldShowAddRewardButton}
                    onclick={() => {
                        state.rewards().push(prop(state.newReward()));
                        h.redraw();
                    }} />
            </>
        )
    }
}

type AddRewardButtonAttrs = {
    shouldDisplayButton: boolean
    onclick(event: Event): void
}

class AddRewardButton implements m.Component {
    view({attrs} : m.Vnode<AddRewardButtonAttrs>) {
        const shouldDisplayButton = attrs.shouldDisplayButton
        const onclick = attrs.onclick

        return (
            shouldDisplayButton &&
            <button class='btn btn-large btn-message show_reward_form new_reward_button add_fields'
            onclick={onclick}>
                {I18n.t('add_reward', I18nScope())}
            </button>
        )
    }
}