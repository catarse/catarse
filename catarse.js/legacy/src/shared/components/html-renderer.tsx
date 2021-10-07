import m from 'mithril'
import { Liquid } from 'liquidjs'
import { useEffect, useMemo, useState, withHooks } from 'mithril-hooks'
import h from '../../h'

export type HTMLRendererProps = {
    html: string;
    variables?: any;
    onRenderWithoutScripts?: (htmlWithoutScripts: string) => void
}

export const HTMLRenderer = withHooks<HTMLRendererProps>(_HTMLRenderer);

function _HTMLRenderer(props: HTMLRendererProps) {
    const { html, variables, onRenderWithoutScripts } = props
    const [ rendered, setRendered ] = useState('')
    const engine = useMemo(() => new Liquid(), [])

    useEffect(() => {
        try {
            const strippedScriptsHtml = h.stripScripts(html)
            const renderedHtml = engine.parseAndRenderSync(strippedScriptsHtml, variables)
            setRendered(renderedHtml)
            if (onRenderWithoutScripts) onRenderWithoutScripts(html)
        } catch (error) {
            console.log('Error on trying render', error)
        }
    }, [html])

    return m.trust(rendered)
}
