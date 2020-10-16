import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import projectCard from './project-card';

const projectRow = {
    view: function({attrs}) {
        const collection = attrs.collection,
            title = attrs.title || collection.title,
            ref = attrs.ref,
            showFriends = attrs.showFriends,
            wrapper = attrs.wrapper || '.w-section.section.u-marginbottom-40';

        if (collection.loader() || collection.collection().length > 0) {
            return m(wrapper, [
                m('.w-container', [
                    (!_.isUndefined(collection.title) || !_.isUndefined(collection.hash)) ? m('.w-row.u-marginbottom-30', [
                        m((showFriends ? '.w-col.w-col-8.w-col-small-6.w-col-tiny-6' : '.w-col.w-col-10.w-col-small-6.w-col-tiny-6'), [
                            m('.fontsize-large.lineheight-looser', title)
                        ]),
                        m((showFriends ? '.w-col.w-col-4.w-col-small-6.w-col-tiny-6' : '.w-col.w-col-2.w-col-small-6.w-col-tiny-6'), [
                            m('.w-row', [
                                (showFriends ? m('.w-col.w-col-6', [
                                    m(`a.btn.btn-no-border.btn-small.btn-terciary[href="/connect-facebook?ref=${ref}"]`, 'Encontrar amigos')
                                ]) : ''),
                                m((showFriends ? '.w-col.w-col-6' : '.w-col.w-col-12'),
                                    m(`a.btn.btn-small.btn-terciary[href="/explore?ref=${ref}&filter=${collection.hash}"]`, {
                                        oncreate: m.route.link
                                    }, 'Ver todos'))
                            ])
                        ])
                    ]) : '',
                    collection.loader() ? h.loader() : m('.w-row', _.map(collection.collection(), project => m(projectCard, {
                        project,
                        ref,
                        showFriends
                    })))
                ])
            ]);
        }
        return m('div');
    }
};

export default projectRow;
