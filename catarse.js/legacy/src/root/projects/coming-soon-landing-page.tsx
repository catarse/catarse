import { ProjectHighlight } from './project-highlight'
import { ProjectDetails, UserDetails } from '../../entities'
import projectVM from '../../vms/project-vm'
import { useState, withHooks } from 'mithril-hooks'
import './coming-soon-landing-page.css'
import { ComingSoonLandingPageBookmarkCard } from './coming-soon-landing-page-bookmark-card'
import ProjectShareBox from '../../c/project-share-box';
import FacebookButton from '../../c/facebook-button';
import AddressTag from '../../c/address-tag';
import CategoryTag from '../../c/category-tag';
import Stream from 'mithril/stream';
import h from '../../h'

export type ComingSoonLandingPageProps = {
    style?: string
    project: ProjectDetails
    user: UserDetails
    isFollowing: boolean
}

export const ComingSoonLandingPage = withHooks<ComingSoonLandingPageProps>(_ComingSoonLandingPage)

function _ComingSoonLandingPage({ style, project, user, isFollowing }: ComingSoonLandingPageProps) {

    const showAddressLinks = false
    const isSubscriptionMode = projectVM.isSubscription(project)
    const hasBackground = Boolean(project.cover_image)
    const linearGradientWithProjectImage = `background-image: linear-gradient(180deg, rgba(0, 4, 8, .82), rgba(0, 4, 8, .82)), url('${project.cover_image}')`
    const [displayShareBox] = useState(h.RedrawToggleStream(false, true))

    return (
        <div id='project-header' style={style} >
            <div class={`w-section section-product ${project.mode}`} />
            <div class={`project-main-container ${isSubscriptionMode ? 'dark' : ''} ${hasBackground ? 'project-with-background' : ''}`}
                style={hasBackground ? linearGradientWithProjectImage : ''}
            >
                <div class={`w-section project-main coming-soon ${isSubscriptionMode ? 'transparent-background' : ''}`}>
                    <div class='w-container'>
                        <div class='w-col w-col-8 project-highlight'>
                            <ProjectHighlight
                                showHeadline={false}
                                showAddressLinks={showAddressLinks}
                                hideEmbed={true}
                                project={project}
                                projectImageChild={
                                    <div class="flag">
                                        <div class="flag-container">
                                            <div>
                                                Em breve no Catarse
                                            </div>
                                        </div>
                                        <div class="flag-curve"></div>
                                    </div>
                                } />
                        </div>
                        <div class='w-col w-col-4'>
                            <ComingSoonLandingPageBookmarkCard
                                project={project}
                                user={user}
                                isFollowing={isFollowing} />
                        </div>
                    </div>

                    <div class='w-container'>
                        <div class="project-share w-hidden-main w-hidden-medium">
                            <div class="u-marginbottom-30">
                                {showAddressLinks && <AddressTag project={Stream(project)} isDark={isSubscriptionMode} />}
                                <CategoryTag project={Stream(project)} isDark={isSubscriptionMode} />
                                {project.recommended && <ProjectWeLovedTag project={Stream(project)} isDark={isSubscriptionMode} />}
                            </div>
                            <div class="u-marginbottom-30 u-text-center-small-only">
                                <button
                                    onclick={() => displayShareBox.toggle()}
                                    class={`btn btn-inline btn-medium btn-terciary ${projectVM.isSubscription(project) ? 'btn-terciary-negative' : ''}`}>
                                    Compartilhar este projeto
                                </button>
                            </div>
                            {
                                displayShareBox() &&
                                <ProjectShareBox
                                    project={Stream(project)}
                                    displayShareBox={displayShareBox} />
                            }
                        </div>
                    </div>

                </div>
            </div>
        </div>
    )
}
