import { withHooks } from 'mithril-hooks'
import { ProjectDetails } from '../../../../entities'
import { PageInfoText } from './page-info-text'

export type ComingSoonDeactivatedProps = {
    project: ProjectDetails
    activate: () => void
}

export const ComingSoonDeactivated = withHooks<ComingSoonDeactivatedProps>(_ComingSoonDeactivated)

function _ComingSoonDeactivated({project, activate}: ComingSoonDeactivatedProps) {
    return (
        <div class="section">
            <div class="w-container">
                <div class="w-row">
                    <div class="w-col w-col-1"></div>
                    <div class="w-col w-col-10">
                        <div class="w-form">
                            <form id="email-form-2" name="email-form-2" data-name="Email Form 2">
                                <div class="u-marginbottom-30 card card-terciary medium w-row">
                                    <div class="w-sub-col w-col w-col-6">
                                        <label for="name-8" class="fontweight-semibold fontsize-base">
                                            Página de pré-lançamento
                                        </label>
                                        <PageInfoText project={project} />
                                    </div>
                                    <div class="w-col w-col-6">
                                        <a onclick={activate} href="#" class="btn btn-medium btn-dark w-button">
                                            Ativar página de pré-lançamento
                                        </a>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                    <div class="w-col w-col-1"></div>
                </div>
            </div>
        </div>
    )
}
