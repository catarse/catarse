import m from 'mithril'
import prop from 'mithril/stream'
import _ from 'underscore'
import h from '../../../h'
import { CardEdit } from './card-edit'
import { ProjectPublishByStepsVM } from '../../../vms/project-publish-by-steps-vm'
import { DescriptionEdit } from './description-edit'
import { AskAboutReward } from './ask-about-reward'
import { RewardsEdit } from './rewards-edit'
import { UserInfoEdit } from './user-info-edit'
import { UserInfoEditViewModel } from '../../../vms/user-info-edit-vm'
import { Todo } from './todo'
import { Share } from './share'
import { ShareReminder } from './share-reminder'
import PopNotification from '../../../c/pop-notification'
import { ThisWindow, I18ScopeType } from '../../../entities/window'

declare var window : ThisWindow

const I18nScope = _.partial(h.i18nScope, 'activerecord') as (params? : {}) => I18ScopeType;

type ProjectsPublishByStepsAttrs = {
    project_id: number
}

type ProjectsPublishByStepsState = {
    projectPublishByStepsVM: ProjectPublishByStepsVM
    userInfoEditVM: UserInfoEditViewModel
    showPopError: (newData? : boolean) => boolean
}

type ProjectsPublishByStepsVnode = m.Vnode<ProjectsPublishByStepsAttrs, ProjectsPublishByStepsState>;

class ProjectsPublishBySteps implements m.Component<ProjectsPublishByStepsAttrs, ProjectsPublishByStepsState> {
    
    oninit({attrs, state} : ProjectsPublishByStepsVnode) {
        state.projectPublishByStepsVM = new ProjectPublishByStepsVM(attrs.project_id)
        state.userInfoEditVM = new UserInfoEditViewModel(attrs.project_id, h.getUserID())
        state.showPopError = h.RedrawStream(false)

        state.projectPublishByStepsVM.error.subscribe(error => {
            h.scrollTop()
            state.showPopError(true)
        })

        state.userInfoEditVM.error.subscribe(error => {
            h.scrollTop()
            state.showPopError(true)
        })
    }

    view({state} : ProjectsPublishByStepsVnode) {
        const projectPublishByStepsVM = state.projectPublishByStepsVM
        const userInfoEditVM = state.userInfoEditVM
        const showPopError = state.showPopError
        const errorMessage = window.I18n.t('publish_by_steps_fields_errors', I18nScope())

        return (
            <>
                <PopNotification error={true} message={errorMessage} toggleOpt={showPopError} />
                {this.renderBody({ projectPublishByStepsVM, userInfoEditVM, showPopError })}
            </>
        )
    }

    private renderBody({ projectPublishByStepsVM, userInfoEditVM, showPopError } : ProjectsPublishByStepsState) {

        if (projectPublishByStepsVM.isLoadingProject || userInfoEditVM.isLoading) {
            return h.loader()
        } else {
            const hash = window.location.hash
            const project = projectPublishByStepsVM.project
            const publishedNotPermittedSteps = [
                '#card',
                '#description',
                '#ask-about-reward',
                '#rewards',
                '#user',
            ]
            const isNotAllowedToPublishedProjects = publishedNotPermittedSteps.includes(hash)

            if (project.is_published && (isNotAllowedToPublishedProjects || hash === '')) {
                window.location.hash = '#to-do'
                h.redraw()
            }

            switch(hash) {
                case '#card': {
                    return (
                        <CardEdit
                            project={projectPublishByStepsVM.project}
                            isSaving={projectPublishByStepsVM.isSaving}
                            save={async coverImageFile => {
                                const canProceed = await projectPublishByStepsVM.save(['uploaded_image', 'headline', 'video_url'], ['uploaded_image', 'headline'], coverImageFile)
                                if (canProceed) {
                                    window.location.hash = '#description'
                                }
                            }}
                            hasErrorOn={(field : string) => projectPublishByStepsVM.hasErrorOn(field)}
                            getFieldErrors={(field : string) => projectPublishByStepsVM.getErrors(field)} />
                    )
                }

                case '#description': {
                    return (
                        <DescriptionEdit 
                            project={projectPublishByStepsVM.project}
                            isSaving={projectPublishByStepsVM.isSaving}
                            save={async (goNext : boolean) => {
                                const fieldsToSave = ['goal', 'about_html', 'permalink', 'city_id']
                                const canProceed = await projectPublishByStepsVM.save(fieldsToSave, fieldsToSave)
                                if (canProceed && goNext) {
                                    window.location.hash = '#ask-about-reward'
                                }
                            }}
                            hasErrorOn={(field : string) => projectPublishByStepsVM.hasErrorOn(field)}
                            getFieldErrors={(field : string) => projectPublishByStepsVM.getErrors(field)} />
                    )
                }

                case '#ask-about-reward': {
                    return (
                        <AskAboutReward project={projectPublishByStepsVM.project} />
                    )
                }

                case '#rewards': {
                    return (
                        <RewardsEdit project={projectPublishByStepsVM.project} />
                    )
                }

                case '#user': {
                    return (
                        <UserInfoEdit 
                            user={userInfoEditVM.user}
                            isSaving={userInfoEditVM.isSaving || projectPublishByStepsVM.isSaving}
                            hasErrorOn={(field : string) => userInfoEditVM.hasErrorOn(field)}
                            getErrorsOn={(field : string) => userInfoEditVM.getErrors(field)}
                            save={async (profileImage? : File) => {
                                const canProceed = await userInfoEditVM.save(profileImage)
                                if (canProceed) {
                                    await projectPublishByStepsVM.publish()
                                    window.location.hash = '#to-do'
                                }
                            }} />
                    )
                }

                case '#to-do': {
                    return (
                        <Todo />
                    )
                }

                case '#share': {
                    return (
                        <Share project={project} />
                    )
                }

                case '#share-reminder': {
                    return (
                        <ShareReminder project={project} />
                    )
                }
    
                default: {
                    if (project.is_published) {
                        window.location.hash = '#to-do'
                    } else {
                        window.location.hash = '#card'
                    }
                }
            }
        }
    }
}

export default ProjectsPublishBySteps