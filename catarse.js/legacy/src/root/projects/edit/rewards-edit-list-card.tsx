import m from 'mithril'
import _ from 'underscore'
import { RewardDetailsStream, StreamType } from '../../../entities/reward-details-stream'
import DashboardRewardCard from '../../../c/dashboard-reward-card'//'../../../c/dashboard-reward-card'
import EditRewardCard from '../../../c/edit-reward-card'
import { ProjectDetails } from '../../../entities/project-details'

export type RewardsEditListCardAttrs = {
    reward: StreamType<RewardDetailsStream>
    index: number
    project: StreamType<ProjectDetails>
    error: StreamType<boolean>
    errors: StreamType<string>
    user: StreamType<{}>
    showSuccess: StreamType<boolean>
    loading: StreamType<boolean>    
    showImageToUpload(reward: any, imageFileToUpload: any, imageInputElementFile: any): void
    deleteImage(reward: any, projectId: any, rewardId: any): Promise<any>
    uploadImage(reward: any, imageFileToUpload: any, projectId: any, rewardId: any): Promise<any>
    class: string
    project_id: number
}

export class RewardsEditListCard implements m.Component {
    view({attrs} : m.Vnode<RewardsEditListCardAttrs>) {
        const reward = attrs.reward
        const index = attrs.index
        const error = attrs.error
        const errors = attrs.errors
        const user = attrs.user
        const showSuccess = attrs.showSuccess
        const project = attrs.project
        const showImageToUpload = attrs.showImageToUpload
        const deleteImage = attrs.deleteImage
        const uploadImage = attrs.uploadImage
        const project_id = attrs.project_id
        const isEditing = reward().edit()

        return (
            <div id={reward().id()}>
                <div class='nested-fields'>
                    <div class='reward-card'>
                        {
                            isEditing ?
                                <EditRewardCard
                                    class={attrs.class}
                                    project_id={project_id}
                                    error={error}
                                    showSuccess={showSuccess}
                                    errors={errors}
                                    reward={reward}
                                    showImageToUpload={showImageToUpload}
                                    deleteImage={deleteImage}
                                    uploadImage={uploadImage}
                                    index={index} />
                                :
                                <DashboardRewardCard
                                    class={attrs.class}
                                    reward={reward}
                                    error={error}
                                    errors={errors}
                                    user={user()}
                                    showSuccess={showSuccess}
                                    project={project}
                                    showImageToUpload={showImageToUpload}
                                    deleteImage={deleteImage}
                                    uploadImage={uploadImage}
                                    index={index} />
                        }
                    </div>
                </div>

                <input type='hidden' value={reward().id()} class='ui-sortable-handle' />
            </div>
        )
    }
}