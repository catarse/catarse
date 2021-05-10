import prop from 'mithril/stream'
import { withHooks } from 'mithril-hooks'
import { ProjectDetails } from '../../../../entities'
import { ComingSoonActivated } from './coming-soon-activated'
import { ComingSoonIntegration } from './controllers/coming-soon.models'
import { ComingSoonDeactivated } from './coming-soon-deactivated'
import ProjectDashboardMenu from '../../../../c/project-dashboard-menu'

export type ProjectComingSoonSwitchProps = {
    comingSoonIntegrationData: ComingSoonIntegration
    project: ProjectDetails
    activate: () => void
    deactivate: () => void
}

export const ProjectComingSoonSwitch = withHooks<ProjectComingSoonSwitchProps>(_ProjectComingSoonSwitch)

function _ProjectComingSoonSwitch({
    comingSoonIntegrationData,
    project,
    activate,
    deactivate
}: ProjectComingSoonSwitchProps) {

    const knowledgeBaseUrl = 'https://suporte.catarse.me/hc/pt-br/articles/4406261323028'

    return (
        <div class="project-coming-soon">

            <div class={`w-section section-product ${project.mode}`}></div>
            {
                project.is_owner_or_admin &&
                <ProjectDashboardMenu project={prop(project)} />
            }

            <div class="w-container">
                <div class="dashboard-header u-text-center">
                    <div class="w-container">
                        <div class="w-row">
                        <div class="w-col w-col-2"></div>
                        <div class="w-col w-col-8">
                            <div class="fontweight-semibold fontsize-larger lineheight-looser">
                                <span class="fontsize-smallest"></span>
                                Sua pré-campanha no Catarse
                            </div>
                            <p class="fontsize-base">
                                Engaje sua comunidade antes mesmo de publicar seu projeto, com sua página de pré-lançamento no Catarse. <a target="_blank" href={knowledgeBaseUrl} class="alt-link">Saiba mais</a>
                            </p>
                        </div>
                        <div class="w-col w-col-2"></div>
                        </div>
                    </div>
                </div>
                {
                    comingSoonIntegrationData ?
                        <ComingSoonActivated
                            project={project}
                            permalink={project.permalink || ''}
                            following={project.reminder_count}
                            deactivate={deactivate} />
                        :
                        <ComingSoonDeactivated project={project} activate={activate} />
                }
            </div>
        </div>
    )
}
