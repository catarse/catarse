import { useEffect, useState, withHooks } from 'mithril-hooks'
import { ProjectDetails, UserDetails } from '../../entities'
import { Loader } from '../../shared/components/loader'
import PopNotification from '../../c/pop-notification'
import userVM from '../../vms/user-vm'
import './coming-soon-landing-page-bookmark-card.scss'
import h from '../../h'
import { ComingSoonLandingPageBookmarkCardRemindButton } from './coming-soon-landing-page-bookmark-card-remind-button'

export type ComingSoonLandingPageBookmarkCardProps = {
    project: ProjectDetails
    user: UserDetails
    isFollowing: boolean
}

export const ComingSoonLandingPageBookmarkCard = withHooks<ComingSoonLandingPageBookmarkCardProps>(_ComingSoonLandingPageBookmarkCard)

function _ComingSoonLandingPageBookmarkCard({ project, user, isFollowing }: ComingSoonLandingPageBookmarkCardProps) {

    const projectNameOrEmpty = project.name || project['project_name'] || ''
    const projectOwnerName = project.user ? userVM.displayName(project.user) : (project.owner_public_name || project.owner_name)
    const userImageUrl = userVM.displayImage(user)

    return (
        <div class="u-text-center-small-only">
            <div class="fontsize-mini fontweight-semibold fontcolor-secondary">
                PRÉ-CAMPANHA
            </div>
            <div class="project-title-coming-soon">
                {projectNameOrEmpty}
            </div>
            <div class="author-coming-soon-wrapper">
                <div class="author-coming-soon-thumb-wrapper">
                    <img src={userImageUrl} width="100" alt="" class="thumb u-marginbottom-30 u-round mini" />
                </div>
                <div class="author-coming-soon-thumb-wrapper">
                    <div class="fontsize-smaller">
                        {projectOwnerName}
                    </div>
                </div>
            </div>
            <div class="fontsize-base u-marginbottom-30">
                {project.headline}
            </div>
            <ComingSoonLandingPageBookmarkCardRemindButton
                project={project}
                isFollowing={isFollowing} />
        </div>
    )
}
