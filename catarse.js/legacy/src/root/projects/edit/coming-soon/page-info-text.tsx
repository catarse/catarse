import { Attributes } from 'mithril';
import { withHooks } from 'mithril-hooks'
import { ProjectDetails } from '../../../../entities'

export type PageInfoTextProps = {
    project: ProjectDetails
} & Partial<Attributes>

export const PageInfoText = withHooks<PageInfoTextProps>(_PageInfoText);

function _PageInfoText({project, ...rest}: PageInfoTextProps) {
    rest.class = `fontsize-smaller fontcolor-secondary ${rest.class}`
    return (
        <div class={rest.class}>
            O Título, Categoria e Link (informados na aba <a href={`/projects/${project.id}/edit#basics`} class="alt-link">Básico</a>) e a Imagem e Frase de Efeito (informados na aba <a href={`/projects/${project.id}/edit#card`} class="alt-link">{project.mode === 'sub' ? 'Imagens' : 'Card do projeto'}</a>) são usados para gerar uma página de pré-lançamento, onde as pessoas podem se cadastrar e receber um email assim que você publicar sua campanha.
        </div>
    )
}
