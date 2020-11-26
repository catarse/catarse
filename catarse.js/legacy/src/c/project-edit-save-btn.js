import m from 'mithril';
import h from '../h';

export default class ProjectEditSaveBtn {
    view({ attrs }) {
        return m('.w-section.save-draft-btn-section', {
            style: (attrs.hideMarginLeft ? { 'margin-left': 0 } : '')
        }, [
            m('.w-row', [
                m('.w-col.w-col-4.w-col-push-4',
                    (attrs.loading() ? h.loader() : [
                        m('input[id="anchor"][name="anchor"][type="hidden"][value="about_me"]'),
                        m('input.btn.btn.btn-large[name="commit"][type="submit"][value="Salvar"]', {
                            onclick: attrs.onSubmit
                        })
                    ])
                ),
                m('.w-col.w-col-4')
            ])
        ]);
    }
};
