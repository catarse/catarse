import m from 'mithril'
import { Event, HTMLInputEvent } from '../../entities'
import h from '../../h'

declare var $ : (...params: any[]) => any

type TextEditorProps = {
    name?: string
    value: string
    onChange(newValue : string): void
    onblur?(event : Event): void
    onfocus?(event : Event): void
    onImageUploaded?(image? : any, json? : any): void
}

export default class {
    view({attrs}: m.Vnode<TextEditorProps>) {
        return TextEditor(attrs)
    }
}

const discardEvent = (event) => ({});

function TextEditor(props : TextEditorProps) {
    const {
        name = '',
        value = '',
        onChange = discardEvent,
        onblur = discardEvent,
        onfocus = discardEvent,
        onImageUploaded = discardEvent,
    } = props

    return (
        <textarea
            name={name}
            class="input_field redactor w-input text-field bottom jumbo positive"
            onupdate={vnodeInner => {
                const $editor = $(vnodeInner.dom)
                $editor.redactor('code.set', value)
            }}
            oncreate={vnodeInner => {
                const $editor = $(vnodeInner.dom)
                const csrf_token = h.authenticityToken()
                const csrf_param = h.authenticityParam()
                const params = (csrf_param && csrf_token && `${csrf_param}=${encodeURIComponent(csrf_token)}`) || ''

                $editor.redactor({
                    ...h.redactorConfig(params),
                    changeCallback: function() {
                        onChange($editor.redactor('code.get'))
                    },
                    imageUploadCallback: onImageUploaded
                })
                $editor.redactor('code.set', value)

                $('.redactor-editor').on('input', (event : string & Event) => {
                    onChange($editor.redactor('code.get'))
                })

                $('.redactor-editor').on('change', (event : string & Event) => {
                    onChange($editor.redactor('code.get'))
                })

                $('.redactor-editor').on('blur', (event : string & Event) => {
                    onChange($editor.redactor('code.get'))
                    onblur(event)
                })

                $('.redactor-editor').on('focus', (event : string & Event) => {
                    onChange($editor.redactor('code.get'))
                    onfocus(event)
                })
            }}>
        </textarea>
    )
}
