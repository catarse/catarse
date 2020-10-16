/**
 * window.c.ContributionActivities component
 * Render a component that pass on confirmed contributions in 24hours interval
 *
 *
 * Example of use:
 * view: () => {
 *     ...
 *     m.component(c.ContributionActivities)
 *     ...
 * }
 */
import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import h from '../h';
import models from '../models';

const contributionActivities = {
    oninit: function(vnode) {
        let interval;
        const collection = prop([]),
            resource = prop(),
            collectionIndex = prop(0),
            collectionSize = prop(),
            collectionL = catarse.loader(
                  models.contributionActivity.getPageOptions()),
            nextResource = () => {
                if ((collectionIndex() + 1) > collectionSize()) {
                    collectionIndex(0);
                }

                collectionIndex(collectionIndex() + 1);
                resource(collection()[collectionIndex()]);
                m.redraw();
            },
            removeTimer = () => clearInterval(interval),
            startTimer = () => {
                interval = setInterval(nextResource, 15000);
            };

        collectionL.load().then((data) => {
            collection(data);
            collectionSize(data.length);
            resource(_.first(data));
        });

        startTimer();

        vnode.state = {
            collection,
            removeTimer,
            collectionL,
            resource,
            collectionSize
        };
    },
    view: function({state, attrs}) {
        if (!state.collectionL() && !_.isUndefined(state.resource()) && (state.collectionSize() || 0) > 0) {
            const resource = state.resource(),
                elapsed = h.translatedTime(resource.elapsed_time),
                projectLink = `https://catarse.me/${resource.permalink}?ref=ctrse_home_activities`;

            return m('.w-section.section.bg-backs-carrosel', { onremove: state.removeTimer }, [
                m('.w-container.u-text-center.fontcolor-negative', [
                    m('.fontsize-large.u-marginbottom-30', `há ${parseInt(elapsed.total)} ${elapsed.unit}...`),
                    m('.w-clearfix.w-inline-block.u-marginbottom-10', [
                        m('a', { href: projectLink }, [
                            m('img.thumb-author.u-round', { src: resource.thumbnail, width: 80 }),
                        ]),
                        m('img.thumb-author.u-round', { src: 'https://daks2k3a4ib2z.cloudfront.net/54b440b85608e3f4389db387/56d646f7710a7126338b46ff_logo-catarse-back-carrosel.png' }),
                        m('a', { href: projectLink }, [
                            m('img.thumb-author.u-round', { src: resource.project_thumbnail, width: 80, style: 'margin-right: 0;' }),
                        ])
                    ]),
                    m('.fontsize-large', `${resource.name} apoiou`),
                    m('.fontsize-larger', [
                        m('a.link-hidden-white', { href: projectLink }, resource.project_name)
                    ])
                ])
            ]);
        }
        return m('div');
    }
};

export default contributionActivities;
