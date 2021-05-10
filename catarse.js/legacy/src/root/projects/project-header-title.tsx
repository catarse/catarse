import m from 'mithril';
import _ from 'underscore';
import userVM from '../../vms/user-vm';
import projectVM from '../../vms/project-vm';
import h from '../../h';
import { ProjectDetails } from '../../entities';
import { Loader } from '../../shared/components/loader';
import { withHooks } from 'mithril-hooks';

export type ProjectHeaderTitleProps = {
    project: ProjectDetails
    children?: JSX.Element
}

export const ProjectHeaderTitle = withHooks<ProjectHeaderTitleProps>(_ProjectHeaderTitle)

function _ProjectHeaderTitle({project, children}: ProjectHeaderTitleProps) {
    if (project) {
        const projectNameOrEmpty = project.name || project['project_name'] || ''
        const isSubscriptionMode = projectVM.isSubscription(project)
        const projectOwnerName = project.user ? userVM.displayName(project.user) : (project.owner_public_name || project.owner_name)

        return (
            <div class={`w-section page-header ${isSubscriptionMode ? 'transparent-background' : ''}`}>
                <div class="w-container">
                    {children}
                    <h1 class="u-text-center fontsize-larger fontweight-semibold project-name">
                        {projectNameOrEmpty}
                    </h1>
                    {
                        isSubscriptionMode ?
                            <div class="w-row">
                                <div class="w-col w-col-6 w-col-push-3">
                                    <p class="fontsize-small lineheight-tight u-margintop-10 u-text-center">
                                        {project.headline}
                                    </p>
                                </div>
                            </div>
                            :
                            <h2 class="u-text-center fontsize-base lineheight-looser" >
                                por {projectOwnerName}
                            </h2>
                    }
                </div>
            </div>
        )
    } else {
        return (
            <Loader />
        )
    }
}
