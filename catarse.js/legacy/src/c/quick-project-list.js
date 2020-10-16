import m from 'mithril';
import _ from 'underscore';
import projectVM from '../vms/project-vm';

const quickProjectList = {
    view: function({attrs}) {
        return m('.quickProjectList', _.map(attrs.projects(), (project, idx) => m('li.u-marginbottom-10', {
            key: idx
        }, m('.w-row',
            [
                m('.w-col.w-col-3',
                                m(`img.thumb.small.u-radius[alt='Project thumb 01'][src='${project.thumb_image || project.video_cover_image}']`)
                            ),
                m('.w-col.w-col-9',
                                m(`a.alt-link.fontsize-smaller[href='/${project.permalink}?ref=ctrse_search_quick']`, {
                                    onclick: projectVM.routeToProject(project, attrs.ref)
                                },
                                    `${project.name}`
                                )
                            )
            ]
                    )
                )), m('li.u-margintop-20',
                  m('.w-row',
                      [
                          m('.w-col.w-col-6',
                              m(`a.btn.btn-terciary[href=${attrs.loadMoreHref}?ref=ctrse_search_quick]`,
                                  'Ver todos'
                              )
                          ),
                          m('.w-col.w-col-6')
                      ]
                  )
              )
        );
    }
};

export default quickProjectList;
