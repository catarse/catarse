import h from '../h';
import m from 'mithril';
import projectsShow from '../root/projects-show';

const projectPreview = {
    view: function({attrs}) {
        return attrs.project() ? m('div', [
            m('.u-text-center',
                m('.w-container',
                    m('.w-row', [
                        m('.w-col.w-col-8.w-col-push-2', [
                            m('.fontweight-semibold.fontsize-large.u-margintop-40',
                                'É hora dos feedbacks!'
                            ),
                            m('p.fontsize-base',
                                'Compartilhe o link abaixo com seus amigos e aproveite o momento para fazer ajustes finos que ajudem na sua campanha.'
                            ),
                            m('.w-row.u-marginbottom-30', [
                                m('.w-col.w-col-3'),
                                m('.w-col.w-col-6',
                                    m(`input.w-input.text-field[type='text'][value='https://www.catarse.me/${attrs.project().permalink}']`)
                                ),
                                m('.w-col.w-col-3')
                            ])
                        ]),
                        m('.w-col.w-col-2')
                    ])
                )
            ),
            m(projectsShow, attrs)
        ]) : h.loader();
    }
};

export default projectPreview;
