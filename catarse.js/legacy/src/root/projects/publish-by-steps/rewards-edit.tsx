import m from 'mithril'
import { RewardsEditTips } from '../../../c/projects/publish-by-steps/rewards-edit-tips'
import { RewardsEditList } from '../../../c/projects/edit/rewards-edit-list'
import { ProjectDetails } from '../../../@types/project-details'
import h from '../../../h'

export type RewardsEditAttrs = {
    project: ProjectDetails
}

export class RewardsEdit implements m.Component {
    view({ attrs } : m.Vnode<RewardsEditAttrs>) {
        const project = attrs.project

        return (
            <div class="section">
                <div class="w-container">
                    <div class="w-row">
                        <div class="w-col w-col-8">
                            <div class="card card-terciary u-radius">
                                <div class="title-dashboard">
                                    Adicione suas recompensas
                                </div>
                                
                                <RewardsEditList 
                                    project_id={project.project_id}
                                    user_id={project.user_id}
                                    project={(newData? : ProjectDetails) => project}
                                    error={h.RedrawStream('')}
                                    errors={h.RedrawStream('')}
                                    showSuccess={h.RedrawStream(false)}
                                    loading={h.RedrawStream(false)} />

                                <div class="u-margintop-40 u-marginbottom-20 w-row">
                                    <div class="w-col w-col-2"></div>
                                    <div class="w-col w-col-8">
                                        <a href="#user" class="btn btn-large">
                                            Próximo &gt;
                                        </a>
                                    </div>
                                    <div class="w-col w-col-2"></div>
                                </div>
                            </div>
                            <div class="u-text-center u-margintop-20 fontsize-smaller">
                                <a href="#ask-about-reward" class="link-hidden-dark">
                                    &lt; Voltar
                                </a>
                            </div>
                        </div>
                        <div class="w-col w-col-4 w-hidden-small w-hidden-tiny">
                            <RewardsEditTips />
                        </div>
                    </div>
                </div>
            </div>
        )
    }
}