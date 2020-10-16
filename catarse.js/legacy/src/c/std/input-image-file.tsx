import m from 'mithril'

export type InputImageFileAttrs = {
    class: string
    oninput(event : Event): void
}

export type InputImageFileState = {
    inputFileElement: HTMLInputElement | null
}

export class InputImageFile implements m.Component {
    view({ attrs, state, children }: m.Vnode<InputImageFileAttrs, InputImageFileState>) {

        const onCreateInputFile = (vnode : m.VnodeDOM) => state.inputFileElement = vnode.dom as HTMLInputElement
        const oninput = attrs.oninput
        const onLoadFileButton = (event: Event) => {
            event.preventDefault()
            if (state.inputFileElement) {
                state.inputFileElement.click()
            }
        }

        return (
            <>
                <input oncreate={onCreateInputFile} oninput={oninput} type="file" accept="image/*" style="display: none;" />
                <span onclick={onLoadFileButton} class={attrs.class}>
                    {children}
                </span>
            </>
        )
    }
}