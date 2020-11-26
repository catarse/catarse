import m from 'mithril'

export type PreviewProjectPageAttrs = {
    project_id: number
    show: boolean
    onClose(): void
}

export class PreviewProjectPage implements m.Component {
    view({ attrs } : m.Vnode<PreviewProjectPageAttrs>) {
        
        const project_id = attrs.project_id
        const show = attrs.show
        const onClose = attrs.onClose

        return (
            show &&
            <div class='modal-backdrop' style='display: block;' onclick={onClose}>
                <div class='modal-dialog-outer'>
                    <div class='modal-dialog-inner modal-dialog-big w-clearfix'>
                        <a onclick={onClose} href='#description' class='modal-close fa fa-close fa-lg w-inline-block'></a>
                        <div class="modal-dialog-header">
                            <div class="fontsize-large u-text-center">
                                Modo de pré-visualização
                            </div>
                        </div>
                        <div class='div-block-6' style='overflow: hidden;'>
                            <iframe src={`/projects/${project_id}?is_preview_without_dashboard_menu=true#preview`} style='width: 100%; height: 100%;'></iframe>
                        </div>
                    </div>
                </div>
            </div>   
        )
    }
}