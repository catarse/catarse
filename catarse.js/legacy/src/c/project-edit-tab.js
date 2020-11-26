import m from 'mithril';

const projectEditTab = {
    view: function({attrs}) {
        return m('div.u-marginbottom-80', [
            m(".w-section.dashboard-header.u-text-center[id='dashboard-titles-root']",
              m('.w-container',
                m('.w-row',
                  m('.w-col.w-col-8.w-col-push-2.u-marginbottom-30', [
                      m(".fontweight-semibold.fontsize-larger.lineheight-looser[id='dashboard-page-title']",
                        m.trust(attrs.title)
                       ),
                      m(".fontsize-base[id='dashboard-page-subtitle']",
                        m.trust(attrs.subtitle)
                       )
                  ])
                 )
               ),
             ),
            m('.u-marginbottom-80', attrs.content)
        ]);
    }
};

export default projectEditTab;
