import { useEffect, useRef, useState, withHooks } from 'mithril-hooks'
import { ProjectDetails } from '../../entities'
import { ComingSoonIntegration } from './edit/coming-soon/controllers/coming-soon.models'
import m from 'mithril'
import h from '../../h'
import './preview-header.css'
import { ClipboardField } from '../../shared/components/clipboard-field'

export type PreviewHeaderProps = {
    project: ProjectDetails
    comingSoonIntegration?: ComingSoonIntegration
    onSelectPreview(previewSelected: PreviewHeaderComingSoonLandingPageViewSelected): void
}

export const PreviewHeader = withHooks<PreviewHeaderProps>(_PreviewHeader)

function _PreviewHeader({ project, comingSoonIntegration, onSelectPreview }: PreviewHeaderProps) {
    if (comingSoonIntegration) {
        return (
            <PreviewHeaderComingSoonLandingPage
                project={project}
                comingSoonIntegration={comingSoonIntegration}
                onSelectPreview={onSelectPreview} />
        )
    } else {
        return (
            <PreviewHeaderDraftPage project={project} />
        )
    }
}

export enum PreviewHeaderComingSoonLandingPageViewSelected {
    ComingSoonLandingPage,
    DraftPage
}

type PreviewHeaderComingSoonLandingPageProps = {
    project: ProjectDetails
    comingSoonIntegration: ComingSoonIntegration
    onSelectPreview(previewSelected: PreviewHeaderComingSoonLandingPageViewSelected): void
}

const PreviewHeaderComingSoonLandingPage = withHooks<PreviewHeaderComingSoonLandingPageProps>(_PreviewHeaderComingSoonLandingPage)

function _PreviewHeaderComingSoonLandingPage({ project, comingSoonIntegration, onSelectPreview }: PreviewHeaderComingSoonLandingPageProps) {

    const baseUrl = `${location.protocol}//${location.host}`
    const comingSoonLandingPageUrl = `${baseUrl}/${project.permalink}`
    const permalinkUrl = `${baseUrl}/${comingSoonIntegration.data.draft_url}`
    const [viewSelected, setViewSelected] = useState(PreviewHeaderComingSoonLandingPageViewSelected.ComingSoonLandingPage)
    const permalink = location.pathname.replace(/\/(.*)#?(.*)/g, '$1')
    const knowledgeBaseUrl = 'https://suporte.catarse.me/hc/pt-br/articles/4406261323028#links_lp'

    useEffect(() => {
        if (permalink === project.permalink) {
            selectPreview(PreviewHeaderComingSoonLandingPageViewSelected.ComingSoonLandingPage)
        } else if (permalink === comingSoonIntegration?.data?.draft_url) {
            selectPreview(PreviewHeaderComingSoonLandingPageViewSelected.DraftPage)
        }
    }, [permalink])

    const selectPreview = (preview: PreviewHeaderComingSoonLandingPageViewSelected) => {
        setViewSelected(preview)
        onSelectPreview(preview)
        if (preview === PreviewHeaderComingSoonLandingPageViewSelected.ComingSoonLandingPage) {
            m.route.set(comingSoonLandingPageUrl)
        } else {
            m.route.set(permalinkUrl)
        }
    }

    return (
        <div class="card card-dark">
            <div class="w-container">
                <div class="u-marginbottom-30">
                    <div class="fontweight-semibold fontsize-large u-text-center">
                        Veja como as pessoas verão sua página
                    </div>
                    <div class="w-row">
                        <div class="w-col w-col-2"></div>
                        <div class="w-col w-col-8">
                            <div class="fontsize-small u-text-center">
                                Seu projeto possui esses dois links, que podem ser usados ao mesmo
                                tempo. Em ambos os links, as pessoas podem se cadastrar para receber um email quando o seu projeto for
                                publicado <a target="_blank" href={knowledgeBaseUrl} class="alt-link">Saiba mais</a>.
                                <br />
                            </div>
                        </div>
                        <div class="w-col w-col-2"></div>
                    </div>
                </div>
                <div class="w-row">
                    <div class="w-col w-col-1"></div>
                    <div class="w-col w-col-10">
                        <div class="flex-row card card-terciary u-radius u-marginbottom-30">
                            <div class="flex-column w-form">
                                <div onclick={() => selectPreview(PreviewHeaderComingSoonLandingPageViewSelected.ComingSoonLandingPage)}>
                                    <label class="fontsize-base fontcolor-primary w-radio">
                                        <div class={`w-form-formradioinput w-form-formradioinput--inputType-custom radio-button w-radio-input ${viewSelected === PreviewHeaderComingSoonLandingPageViewSelected.ComingSoonLandingPage ? 'w--redirected-checked' : ''}`}></div>
                                        <span class="fontweight-semibold w-form-label">
                                            Página de pré-lançamento
                                        </span>
                                    </label>
                                    <div class="u-marginbottom-10 fontcolor-secondary">
                                        Útil para compartilhar publicamente e já ir engajando sua comunidade antes mesmo de lançar sua campanha
                                    </div>
                                    <ClipboardField
                                        text={comingSoonLandingPageUrl}
                                        placeholder="www.catarse.me/linkdoprojeto" />
                                </div>
                            </div>
                            <div class="right-divider"></div>
                            <div class="flex-column w-form">
                                <div onclick={() => selectPreview(PreviewHeaderComingSoonLandingPageViewSelected.DraftPage)}>
                                    <label class="fontsize-base fontcolor-primary w-radio">
                                        <div class={`w-form-formradioinput w-form-formradioinput--inputType-custom radio-button w-radio-input ${viewSelected === PreviewHeaderComingSoonLandingPageViewSelected.DraftPage ? 'w--redirected-checked' : ''}`}></div>
                                        <span class="fontweight-semibold w-form-label">
                                            Página de rascunho
                                        </span>
                                    </label>
                                    <div class="u-marginbottom-10 fontcolor-secondary">
                                        Útil para compartilhar com pessoas de confiança e ouvir palpites sobre sua campanha antes do lançamento
                                    </div>
                                    <ClipboardField
                                        text={permalinkUrl}
                                        placeholder="www.catarse.me/linkdoprojeto" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="w-col w-col-1"></div>
                </div>
            </div>
        </div>
    )
}

type PreviewHeaderDraftPageProps = {
    project: ProjectDetails
}

const PreviewHeaderDraftPage = withHooks<PreviewHeaderDraftPageProps>(_PreviewHeaderDraftPage)

function _PreviewHeaderDraftPage({ project }: PreviewHeaderDraftPageProps) {

    const baseUrl = `${location.protocol}//${location.host}`
    const permalinkUrl = `${baseUrl}/${project.permalink}`

    return (
        <div class="card card-dark">
            <div class="w-container">
                <div class="u-marginbottom-30">
                    <div class="fontweight-semibold fontsize-large u-text-center">
                        Veja como as pessoas verão sua página
                    </div>
                </div>
                <div class="w-row">
                    <div class="w-col w-col-1"></div>
                    <div class="w-col w-col-10">
                        <div class="flex-row card card-terciary u-radius u-marginbottom-30">
                            <div class="flex-column w-form">
                                <div>
                                    <div class="fontsize-small fontcolor-primary">
                                        Compartilhe o link ao lado com pessoas de confiança e receba palpites sobre sua campanha antes do lançamento.
                                        <br />
                                        <br />
                                    </div>
                                </div>
                            </div>
                            <div class="right-divider"></div>
                            <div class="flex-column w-form">
                                <form>
                                    <label class="fontsize-base fontcolor-primary">
                                        <span class="fontweight-semibold w-form-label">
                                            Página de rascunho
                                        </span>
                                    </label>
                                    <ClipboardField
                                        text={permalinkUrl}
                                        placeholder="www.catarse.me/linkdoprojeto" />
                                </form>
                            </div>
                        </div>
                    </div>
                    <div class="w-col w-col-1"></div>
                </div>
            </div>
        </div>
    )
}
