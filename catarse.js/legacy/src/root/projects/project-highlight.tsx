import ProjectShareBox from '../../c/project-share-box';
import FacebookButton from '../../c/facebook-button';
import AddressTag from '../../c/address-tag';
import CategoryTag from '../../c/category-tag';
import { ProjectWeLovedTag } from '../../c/project-we-loved-tag';
import projectVM from '../../vms/project-vm';
import { ProjectVideo } from './project-video';
import { useState, withHooks } from 'mithril-hooks';
import { ProjectDetails } from '../../entities';
import Stream from 'mithril/stream';
import { Loader } from '../../shared/components/loader';

export type ProjectHighlightProps = {
    project: ProjectDetails
    projectImageChild?: JSX.Element
    hideEmbed: boolean
    showHeadline: boolean
    showAddressLinks: boolean
}

export const ProjectHighlight = withHooks<ProjectHighlightProps>(_ProjectHighlight)

function _ProjectHighlight(props: ProjectHighlightProps) {
    const {
        project,
        projectImageChild,
        hideEmbed,
        showHeadline = true,
        showAddressLinks = true
    } = props;

    const [displayShareBox, setDisplayShareBox] = useState(false)

    if (project) {
        const isSubscriptionMode = projectVM.isSubscription(project)
        const facebookUrl = `https://www.catarse.me/${project.permalink}?ref=ctrse_project_share&utm_source=facebook.com&utm_medium=social&utm_campaign=ctrse_project_share`
        const messengerUrl = `https://www.catarse.me/${project.permalink}?ref=ctrse_project_share&utm_source=facebook_messenger&utm_medium=social&utm_campaign=ctrse_project_share`

        const projectCoveImageBackgroundStyle = `background-image:url('${project.original_image || project['project_img'] || project.video_cover_image}');`
        const hasPermalink = !!project.permalink

        return (
            <div id="project-highlight">
                {
                    project.video_embed_url ?
                        <ProjectVideo video_embed_url={project.video_embed_url} />
                        :
                        <div class="project-image" style={projectCoveImageBackgroundStyle}>
                            {projectImageChild}
                        </div>
                }
                <div class="w-hidden-small w-hidden-tiny">
                    {
                        showAddressLinks &&
                        <AddressTag project={Stream(project)} isDark={isSubscriptionMode} />
                    }
                    <CategoryTag project={Stream(project)} isDark={isSubscriptionMode} />
                    {
                        project.recommended &&
                        <ProjectWeLovedTag project={Stream(project)} isDark={isSubscriptionMode} />
                    }
                </div>
                {
                    !isSubscriptionMode && showHeadline &&
                    <div class="project-blurb">
                        {project.headline}
                    </div>
                }
                <div class="project-share w-hidden-small w-hidden-tiny">
                    <div class="u-marginbottom-30 u-text-center-small-only">
                        <div class="w-inline-block fontcolor-secondary fontsize-smaller u-marginright-20">
                            Compartilhar:
                        </div>
                        {
                            hasPermalink &&
                            <FacebookButton class={isSubscriptionMode ? 'btn-terciary-negative' : ''} url={facebookUrl} />
                        }
                        {
                            hasPermalink &&
                            <FacebookButton class={isSubscriptionMode ? 'btn-terciary-negative' : ''} url={messengerUrl} messenger={true} />
                        }
                        <button onclick={() => setDisplayShareBox(!displayShareBox)} id="more-share" class={`btn btn-inline btn-medium btn-terciary ${isSubscriptionMode ? 'btn-terciary-negative' : ''}`} style="transition: all 0.5s ease 0s">
                            ··· Mais
                        </button>
                        {
                            displayShareBox &&
                            <ProjectShareBox
                                project={Stream(project)}
                                displayShareBox={{toggle() { setDisplayShareBox(!displayShareBox) }}}
                                facebookUrl={facebookUrl}
                                messengerUrl={messengerUrl}
                                hideEmbed={hideEmbed}
                                />
                        }
                    </div>
                </div>
            </div>
        )
    } else {
        return (
            <Loader />
        )
    }
}
