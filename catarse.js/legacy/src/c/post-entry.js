import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const postEntry = {
    view: ({state, attrs}) => {
        const 
            post = attrs.post,
            project = attrs.project,
            showOpenPercentage = attrs.showOpenPercentage,
            deletePost = attrs.deletePost,
            destinatedTo = attrs.destinatedTo;

        return m('.table-row.w-row', [
            m('.table-col.w-col.w-col-5', [
                m(`a.alt-link.fontsize-base[href='/projects/${project.project_id}/posts/${post.id}#posts'][target='_blank']`,
                        post.title
                    ),
                m('.fontcolor-secondary.fontsize-smallest', [
                    m('span.fontweight-semibold',
                            'Enviada em: '
                        ),
                    h.momentify(post.created_at, 'DD/MM/YYYY, h:mm A')
                ]),
                m('.fontcolor-secondary.fontsize-smallest', [
                    m('span.fontweight-semibold', 'Destinatários: '),
                    m('span', destinatedTo)
                ])
            ]),
            m('.table-col.u-text-center.w-col.w-col-3',
                    m('.fontsize-base',
                        post.delivered_count
                    )
                ),
            m('.table-col.u-text-center.w-col.w-col-3',
                    m('.fontsize-base', [
                        post.open_count,
                        m('span.fontcolor-secondary', ` (${showOpenPercentage}%)`)
                    ])
                ),
            m('.table-col.w-col.w-col-1',
                    m('button.btn.btn-no-border.btn-small.btn-terciary.fa.fa-lg.fa-trash', {
                        onclick: deletePost()
                    })
                )
        ]);
    }
};

export default postEntry;