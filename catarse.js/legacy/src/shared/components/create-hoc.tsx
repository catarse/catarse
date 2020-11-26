import { withHooks } from 'mithril-hooks'
import { Component } from 'mithril'

export type CreateHOCProps<InjectableStructure, WrappedComponentProps> = {
    WrappedComponent: Component<WrappedComponentProps>
    injectable: InjectableStructure
}

export function CreateHOC<InjectableStructure, WrappedComponentProps>(props : CreateHOCProps<InjectableStructure, WrappedComponentProps>) {

    const {
        WrappedComponent,
        injectable,
    } = props

    return withHooks<WrappedComponentProps>(innerProps => (
        <WrappedComponent {...innerProps} {...injectable} />
    ))
}