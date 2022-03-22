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
            O Título, Categoria e Link (informados na aba Básico), a Imagem e Frase de Efeito (informados na aba {project.mode === 'sub' ? 'Imagens' : 'Card do projeto'}) ou o vídeo (informado na aba {project.mode === 'sub' ? 'Descrição' : 'Vídeo'} ) são usados para gerar uma página de pré-lançamento, onde as pessoas podem se cadastrar e receber um email assim que você publicar sua campanha.
        </div>
    )
}
