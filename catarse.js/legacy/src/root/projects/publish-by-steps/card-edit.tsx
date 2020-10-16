import m, { VnodeDOM } from 'mithril'
import { ProjectCardSimple } from '../../../c/projects/publish-by-steps/project-card-simple'
import { ProjectDetails } from '../../../@types/project-details'
import h from '../../../h'
import InlineError from '../../../c/inline-error'
import { InlineErrors } from '../../../c/inline-errors'
import { InputImageFile } from '../../../c/std/input-image-file'

export type CardEditAttrs = {
    project: ProjectDetails
    isSaving: boolean
    save(imageFile : File): void
    hasErrorOn(field : string) : boolean
    getFieldErrors(field : string) : string[]
}

export type CardEditState = {
    selectedImageFile: File
    inputFileElement: HTMLInputElement
}

export class CardEdit implements m.Component {
    oninit({state} : m.Vnode<CardEditAttrs, CardEditState>) {
        state.selectedImageFile = null
        state.inputFileElement = null
    }

    view({ attrs, state } : m.Vnode<CardEditAttrs, CardEditState>) {
        
        const project = attrs.project
        const isSaving = attrs.isSaving
        const save = attrs.save
        const hasErrorOn = attrs.hasErrorOn
        const getFieldErrors = attrs.getFieldErrors

        return (
            <div class="section">
                <div class="w-container">
                    <div class="w-row">
                        <div class="w-col w-col-8">
                            <div class="card medium card-terciary u-radius w-form">
                                <form id="email-form-4" name="email-form-4" data-name="Email Form 4">
                                    <div class="title-dashboard">
                                        <span class="fontsize-smallest"></span>
                                        Escolha a imagem do seu projeto
                                    </div>
                                    <div class="u-marginbottom-40 w-row">
                                        <div class="_w-sub-col w-col w-col-5">
                                            <label for="name" class="field-label fontweight-semibold">
                                                Imagem do projeto
                                            </label>
                                            <label for="name" class="field-label fontsize-smallest fontcolor-secondary">
                                                Tamanho recomendado 720x400px
                                            </label>
                                        </div>
                                        <div class="_w-sub-col w-col w-col-4">
                                            <InputImageFile 
                                                class='btn btn-small btn-dark'
                                                oninput={(event : Event) => {
                                                    const files = (event.target as HTMLInputElement).files
                                                    if (files.length > 0) {
                                                        if (project.large_image && project.large_image.indexOf('blob') >= 0) {
                                                            URL.revokeObjectURL(project.large_image)
                                                        }

                                                        state.selectedImageFile = files[0]
                                                        project.large_image = URL.createObjectURL(state.selectedImageFile)
                                                    }
                                            }}>
                                                Escolher arquivo
                                            </InputImageFile>
                                        </div>
                                        <div class="w-col w-col-3">
                                            <div class="fontsize-smallest fontcolor-secondary" style='padding-left: 4px;'>
                                                {
                                                    state.selectedImageFile !== null ?
                                                        `${state.selectedImageFile.name}`
                                                        :
                                                        'Nenhum arquivo escolhido'
                                                }
                                            </div>
                                        </div>
                                        
                                        <InlineErrors messages={getFieldErrors('uploaded_image')} />
                                    </div>

                                    <div class="u-marginbottom-40 w-row">
                                        <div class="_w-sub-col w-col w-col-5">
                                            <label for="name" class="field-label fontweight-semibold">
                                                Frase de efeito
                                            </label>
                                            <label for="name" class="field-label fontsize-smallest fontcolor-secondary">
                                                Máximo de 100 caracteres
                                            </label>
                                        </div>
                                        <div class="w-col w-col-7">
                                            <textarea
                                                maxlength="100" 
                                                placeholder="Um resuminho do seu projeto em até 100 caracteres"
                                                value={project.headline}
                                                oninput={(event : Event) => project.headline = event.target.value}
                                                class={`text-field positive w-input ${hasErrorOn('headline') && 'error'}`}
                                                required>
                                            </textarea>
                                            <InlineErrors messages={getFieldErrors('headline')} />
                                        </div>
                                    </div>
                                    <div class="u-marginbottom-40 w-row">
                                        <div class="_w-sub-col w-col w-col-5">
                                            <label for="name" class="field-label fontweight-semibold">
                                                Vídeo do youtube (opcional)
                                            </label>
                                            <label for="name" class="field-label fontsize-smallest fontcolor-secondary">
                                                Vídeo que é exibido na página principal da campanha
                                            </label>
                                        </div>
                                        <div class="w-col w-col-7">
                                            <input 
                                                oninput={(event : Event) => project.video_url = event.target.value}
                                                type="text"
                                                class="text-field positive w-input"
                                                maxlength="3000"
                                                placeholder="www.youtube.com/seuvideo"
                                                value={project.video_url}/>
                                        </div>
                                    </div>
                                    <div class="u-margintop-40 w-row">
                                        <div class="w-col w-col-3"></div>
                                        <div class="w-col w-col-6">
                                            {
                                                isSaving ?
                                                    h.loader()
                                                    :
                                                    <button onclick={() => save(state.selectedImageFile)} class="btn btn-large">
                                                        Próximo &gt;
                                                    </button>
                                            }
                                        </div>
                                        <div class="w-col w-col-3"></div>
                                    </div>
                                </form>
                            </div>
                        </div>
                        <div class="w-col w-col-4">
                            <div class="u-margintop-40">
                                <ProjectCardSimple 
                                    name={project.name} 
                                    headline={project.headline}
                                    image={project.large_image}
                                    />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
};