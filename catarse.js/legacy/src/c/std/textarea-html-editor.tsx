import m from 'mithril'
import h from '../../h'

export type TextareaHtmlEditorAttrs = {
    class: string
    html: string
    onChange(html : string): void
    onfocus(event : Event): void
    onblur(event : Event): void
}

export class TextareaHtmlEditor implements m.Component {
    view({ attrs } : m.Vnode<TextareaHtmlEditorAttrs>) {
        const attrsWithDefaultClasses = {
            ...attrs,
            onChange: (value : any) => {},
            class: `input_field redactor w-input text-field bottom jumbo positive ${attrs.class}`
        }

        const onChange = attrs.onChange
        const html = attrs.html

        return (
            <textarea {...attrsWithDefaultClasses}
                oncreate={(vnode : m.VnodeDOM) => {
                    const configureRedactor = h.setRedactor((newHtml?: string) => {
                        if (typeof newHtml !== 'undefined') {
                            onChange(newHtml)
                        }
            
                        return html
                    })

                    configureRedactor(vnode)
                }}>

            </textarea>
        )
    }
}