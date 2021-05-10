import ProjectPage from './project-page'
import { ProjectDetails, UserDetails } from '../../entities'
import m from 'mithril'
import { Loader } from '../../shared/components/loader'
import { useLayoutEffect, useState, withHooks } from 'mithril-hooks'
import { PreviewHeader, PreviewHeaderComingSoonLandingPageViewSelected } from './preview-header'
import { comingSoonIntegration } from './edit/coming-soon/controllers/coming-soon-integration'
import { ComingSoonLandingPage } from './coming-soon-landing-page'
import projectVM from '../../vms/project-vm'
import { remind } from './controllers/remind'
import { removeRemind } from './controllers/removeRemind'
import ProjectDashboardMenu from '../../c/project-dashboard-menu';

type ProjectShowProps = {
    project_id: number
    project_user_id: number
    post_id: number
    hideDashboardMenu: boolean
}

export const ProjectShow = withHooks<ProjectShowProps>(_ProjectShow)

function _ProjectShow({ project_id, project_user_id, post_id, ...rest }: ProjectShowProps) {
    const [previewSelected, setPreviewSelected] = useState<PreviewHeaderComingSoonLandingPageViewSelected>(PreviewHeaderComingSoonLandingPageViewSelected.ComingSoonLandingPage)
    const project = projectVM.currentProject()
    const comingSoonIntegrationData = comingSoonIntegration(project)
    const permalink = location.pathname.replace(/\/(.*)/, '$1')
    const isProjectPageDraftAccess = comingSoonIntegrationData?.data?.draft_url === permalink
    const query: { [key:string]: any } = m.parseQueryString(location.search)

    const shouldDisplayPreviewHeader = project && project.is_owner_or_admin && project.state === 'draft' && comingSoonIntegrationData
    const shouldDisplayComingSoonPage = project &&
        (project.permalink === permalink || !isProjectPageDraftAccess)
        && project.state === 'draft' && comingSoonIntegrationData

    const onSelectPreview = (previewSelected: PreviewHeaderComingSoonLandingPageViewSelected) => setPreviewSelected(previewSelected)

    useLayoutEffect(() => {
        if (project_id && !isNaN(Number(project_id))) {
            projectVM.init(project_id, project_user_id);
        } else {
            projectVM.getCurrentProject();
        }
    }, [ project_id, project_user_id ])

    if (project) {
        const shouldDisplayDashboardMenu = project && project.is_owner_or_admin && !rest.hideDashboardMenu && !query.is_preview_without_dashboard_menu;

        return (
            <>
                {
                    shouldDisplayDashboardMenu &&
                    <ProjectDashboardMenu project={projectVM.currentProject} />
                }
                {
                    shouldDisplayPreviewHeader ?
                        <div>
                            <PreviewHeader
                                project={project}
                                comingSoonIntegration={comingSoonIntegrationData}
                                onSelectPreview={onSelectPreview}/>

                            {
                                previewSelected === PreviewHeaderComingSoonLandingPageViewSelected.DraftPage ?
                                    <ProjectPage
                                        project_id={project_id}
                                        project_user_id={project_user_id}
                                        post_id={post_id}
                                        {...rest} />
                                    :
                                    <ComingSoonLandingPage
                                        project={project}
                                        user={projectVM.userDetails() as UserDetails}
                                        isFollowing={project.in_reminder} />
                            }
                        </div>
                        :
                        shouldDisplayComingSoonPage ?
                            <ComingSoonLandingPage
                                project={project}
                                user={projectVM.userDetails() as UserDetails}
                                isFollowing={project.in_reminder} />
                            :
                            <ProjectPage
                                project_id={project_id}
                                project_user_id={project_user_id}
                                post_id={post_id}
                                {...rest} />
                }
            </>
        )
    } else {
        return (
            <Loader />
        )
    }
}
