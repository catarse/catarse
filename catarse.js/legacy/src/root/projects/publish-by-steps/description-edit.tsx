import m from 'mithril'
import h from '../../../h'
import { ProjectDetails } from '@/entities/project-details'
import { DescriptionEditTips } from './description-edit-tips'
import { InputCurrency } from '../../../c/std/input-currency'
import { InlineErrors } from '../../../c/inline-errors'
import { TextareaHtmlEditor } from '../../../c/std/textarea-html-editor'
import { InputFindLocation } from '../../../c/std/input-find-location'
import { City } from '../../../entities/city'
import { PreviewProjectPage } from './preview-project-page'
import { InputPermalink } from './input-permalink'
import { AmountEditTips } from './amount-edit-tips'


export type DescriptionEditAttrs = {
    project: ProjectDetails
    isSaving: boolean
    save(goNext: boolean): Promise<void>
    getFieldErrors(field : string): string[]
    hasErrorOn(field : string): boolean
}

export type DescriptionEditState = {
    showPreview(newValue?: boolean) : boolean
    showDescriptionTips(newValue?: boolean) : boolean
    showAmountTips(newValue?: boolean) : boolean
}

export class DescriptionEdit implements m.Component {

    oninit({ attrs, state } : m.Vnode<DescriptionEditAttrs, DescriptionEditState> ) {
        state.showPreview = h.RedrawStream(false)
        state.showDescriptionTips = h.RedrawStream(false)
        state.showAmountTips = h.RedrawStream(false)
    }

    view({ attrs, state }: m.Vnode<DescriptionEditAttrs, DescriptionEditState>) {

        const project = attrs.project
        const isSaving = attrs.isSaving
        const save = attrs.save
        const getFieldErrors = attrs.getFieldErrors
        const hasErrorOn = attrs.hasErrorOn
        const showPreview = state.showPreview
        const showAmountTips = state.showAmountTips
        const showDescriptionTips = state.showDescriptionTips

        return (
            <>            
                <PreviewProjectPage show={showPreview()} onClose={() => showPreview(false)} project_id={project.id} />

                <div class="section">
                    <div class="w-container">
                        <div class="w-row">
                            <div class="w-col w-col-8">
                                <div class="card medium card-terciary u-radius w-form">
                                    <form>
                                        <div class="title-dashboard">
                                            Fale sobre o seu projeto
                                    </div>
                                        <div class="u-marginbottom-30">
                                            <label for="name-26" class="field-label fontweight-semibold u-marginbottom-10">
                                                Quanto você quer arrecadar?
                                            </label>
                                            <div class="u-marginbottom-20 w-row">
                                                <div class="w-col w-col-3 w-col-small-3 w-col-tiny-3">
                                                    <div class="back-reward-input-reward placeholder">R$</div>
                                                </div>
                                                <div class="w-col w-col-9 w-col-small-9 w-col-tiny-9">
                                                    <InputCurrency 
                                                        class={`${hasErrorOn('goal') ? 'error' : ''}`} 
                                                        value={project.goal}
                                                        placeholder='0,00'
                                                        onValueChange={newValue => project.goal = newValue} 
                                                        onfocus={(event : Event) => {
                                                            showAmountTips(true)
                                                        }}
                                                        onblur={(event : Event) => {
                                                            showAmountTips(false)
                                                        }}
                                                        />
                                                    <InlineErrors messages={getFieldErrors('goal')} />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="u-marginbottom-30">
                                            <label for="name" class="field-label fontweight-semibold u-marginbottom-10">
                                                Descrição do projeto
                                            </label>
                                            <TextareaHtmlEditor 
                                                html={project.about_html} 
                                                class={`${hasErrorOn('about_html') ? 'error' : ''}`}
                                                onChange={(newHtml : string) => {
                                                    project.about_html = newHtml
                                                }}
                                                onfocus={(event : Event) => {
                                                    showDescriptionTips(true)
                                                }}
                                                onblur={(event : Event) => {
                                                    showDescriptionTips(false)
                                                }} />
                                            <InlineErrors messages={getFieldErrors('about_html')} />
                                        </div>
                                        <div class="u-marginbottom-30 w-row">
                                            <div class="_w-sub-col w-col w-col-5">
                                                <label for="name-7" class="field-label fontweight-semibold">Link do projeto</label></div>
                                            <div class="w-col w-col-7">
                                                <div class="w-row">
                                                    <div class="text-field prefix no-hover w-col w-col-4 w-col-small-6 w-col-tiny-6">
                                                        <div class="fontcolor-secondary u-text-center fontsize-smallest">catarse.me/</div>
                                                    </div>
                                                    <div class="w-col w-col-8 w-col-small-6 w-col-tiny-6">
                                                        <InputPermalink 
                                                            autoResetLastValidValue={false}
                                                            class={`${hasErrorOn('permalink') ? 'error' : ''}`} 
                                                            currentPermalink={project.permalink} 
                                                            onChange={(newPermalink : string) => project.permalink = newPermalink}
                                                            onValidChange={(newPermalink : string) => project.permalink = newPermalink} />
                                                    </div>
                                                </div>
                                                <InlineErrors messages={getFieldErrors('permalink')} />
                                            </div>
                                        </div>
                                        <div class="u-marginbottom-30">
                                            <div class="w-row">
                                                <div class="w-col w-col-5">
                                                    <label for="name-9" class="field-label fontweight-semibold">
                                                        Local do projeto
                                                    <br />
                                                    </label>
                                                </div>
                                                <div class="w-col w-col-7">
                                                    <InputFindLocation 
                                                        class={`${hasErrorOn('city_id') ? 'error' : ''}`} 
                                                        city_id={project.city_id} 
                                                        onSelect={(city : City) => project.city_id = Number(city.id)}/>
                                                    <InlineErrors messages={getFieldErrors('city_id')} />
                                                </div>
                                            </div>
                                        </div>

                                        {
                                            isSaving ?
                                                h.loader()
                                                :
                                                <>
                                                    <div class="u-margintop-40 u-marginbottom-20 w-row">
                                                        <div class="w-col w-col-2"></div>
                                                        <div class="w-col w-col-8">
                                                            <a onclick={async () => await save(true)} href="#description" class="btn btn-large">
                                                                Próximo &gt;
                                                            </a>
                                                        </div>
                                                        <div class="w-col w-col-2"></div>
                                                    </div>
                                                    <div class="w-row">
                                                        <div class="w-col w-col-2"></div>
                                                        <div class="w-col w-col-4">
                                                            <a onclick={async () => {
                                                                await save(false)
                                                                showPreview(true)
                                                            }} href="#description" class="btn btn-medium btn-terciary" data-ix="show-modal" style="transition: all 0.5s ease 0s;">
                                                                Ver página
                                                            </a>
                                                        </div>
                                                        <div class="w-col w-col-4">
                                                            <a onclick={async () => await save(false)} href="#description" class="btn btn-medium btn-terciary" data-ix="show-modal" style="transition: all 0.5s ease 0s;">
                                                                Salvar
                                                            </a>
                                                        </div>
                                                        <div class="w-col w-col-2"></div>
                                                    </div>
                                                </>
                                        }
                                    </form>
                                </div>
                                <div class="u-text-center u-margintop-20 fontsize-smaller">
                                    <a href="#card" class="link-hidden-dark">
                                        &lt; Voltar
                                    </a>
                                </div>
                            </div>

                            <div class="w-col w-col-4  w-hidden-tiny w-hidden-small">
                                <AmountEditTips show={showAmountTips()} />
                                <DescriptionEditTips show={showDescriptionTips()} />
                            </div>
                        </div>
                    </div>
                </div>
            </>
        )
    }
}