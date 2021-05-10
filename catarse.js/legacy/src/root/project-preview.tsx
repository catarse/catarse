import ProjectPage from './projects/project-page';
import { ProjectDetails, UserDetails } from '../entities';
import { Stream } from 'mithril/stream';
import { Loader } from '../shared/components/loader'
import { useState, withHooks } from 'mithril-hooks';
import { PreviewHeader, PreviewHeaderComingSoonLandingPageViewSelected } from './projects/preview-header';
import { comingSoonIntegration } from './projects/edit/coming-soon/controllers/coming-soon-integration'
import { ComingSoonLandingPage } from './projects/coming-soon-landing-page';
import projectVM from '../vms/project-vm';

type ProjectPreviewProps = {
    project: Stream<ProjectDetails>
}

export const ProjectPreview = withHooks<ProjectPreviewProps>(_ProjectPreview)

function _ProjectPreview(props: ProjectPreviewProps) {
    const comingSoonIntegrationData = comingSoonIntegration(props.project())
    const [previewSelected, setPreviewSelected] = useState<PreviewHeaderComingSoonLandingPageViewSelected>(
        comingSoonIntegrationData ? PreviewHeaderComingSoonLandingPageViewSelected.ComingSoonLandingPage : PreviewHeaderComingSoonLandingPageViewSelected.DraftPage
    )
    const onSelectPreview = (previewSelected: PreviewHeaderComingSoonLandingPageViewSelected) => setPreviewSelected(previewSelected)

    if (props.project()) {
        return (
            <div>
                <PreviewHeader
                    project={props.project()}
                    comingSoonIntegration={comingSoonIntegrationData}
                    onSelectPreview={onSelectPreview}/>
                {
                    previewSelected === PreviewHeaderComingSoonLandingPageViewSelected.DraftPage ?
                        <ProjectPage {...props}/>
                        :
                        <ComingSoonLandingPage
                            project={props.project()}
                            user={projectVM.userDetails() as UserDetails}
                            isFollowing={false} />
                }
            </div>
        )
    } else {
        return (
            <Loader />
        )
    }
}
