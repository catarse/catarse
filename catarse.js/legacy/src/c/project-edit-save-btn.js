import m from 'mithril';
import h from '../h';

const projectEditSaveBtn = {
    view: function({attrs}) {
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

export default projectEditSaveBtn;
