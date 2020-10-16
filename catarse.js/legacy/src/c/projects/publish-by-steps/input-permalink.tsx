import m from 'mithril'
import { fromEvent } from 'rxjs'
import { debounceTime } from 'rxjs/operators'
import h from '../../../h'

export type InputPermalinkAttrs = {
    currentPermalink: string
    onValidChange(permalink : string): void
    onChange(permalink : string): void
    class: string
    autoResetLastValidValue: boolean
}

export type InputPermalinkState = {
    currentPermalink: string
    class: string
    checkPermalinkAvailable(inputText : string): void
}

export class InputPermalink implements m.Component {

    oninit({ state, attrs} : m.Vnode<InputPermalinkAttrs, InputPermalinkState>) {
        state.class = attrs.class
        state.currentPermalink = attrs.currentPermalink
        state.checkPermalinkAvailable = async (inputText) => {
            let lastValidValue = state.currentPermalink
            state.currentPermalink = inputText
            try {
                const projectBySlugRequestConfig = {
                    method: 'GET',
                    url: `/${inputText}.html`,
                    config: h.setCsrfToken,
                    deserialize: function(value) { return value }
                }
                
                await m.request(projectBySlugRequestConfig)
                if (state.currentPermalink !== attrs.currentPermalink) {
                    state.class = 'error'
                }

                if (attrs.autoResetLastValidValue) {
                    state.currentPermalink = lastValidValue
                    h.redraw()
                }
            } catch(e) {
                state.class = ''

                if (typeof attrs.onValidChange === 'function') {
                    attrs.onValidChange(state.currentPermalink)
                }

                if (typeof attrs.onChange === 'function') {
                    attrs.onChange(state.currentPermalink)
                }
            }

            if (typeof attrs.onChange === 'function') {
                attrs.onChange(state.currentPermalink)
            }
        }
    }

    oncreate({ state, attrs, dom} : m.VnodeDOM<InputPermalinkAttrs, InputPermalinkState>) {
        const oninput = fromEvent(dom, 'input')
        const oneveryinput = oninput.pipe()
        const wait1s = oneveryinput.pipe(debounceTime(1000))

        oneveryinput.subscribe(event => {
            state.class = ''
        })
        
        wait1s.subscribe(event => {
            state.checkPermalinkAvailable(event.target.value)
        })
    }

    view({ state, attrs} : m.Vnode<InputPermalinkAttrs, InputPermalinkState>) {
        
        const currentPermalink = state.currentPermalink

        state.class = state.class || attrs.class

        return (
            <input 
                value={currentPermalink}
                type="text" 
                id="project-parmalink-id" 
                maxlength="256" 
                placeholder="seu_link_no_catarse" 
                class={`text-field postfix positive w-input ${state.class}`} />
        )
    }
}