import m from 'mithril';

const userSettingsHelp = {
    view: function ({state, attrs}) {
        return m('.w-col.w-col-4', [
            m('.card.u-radius.card-message.u-marginbottom-20',
                [
                    m('.fontsize-small.u-marginbottom-10',
                        [
                            m('span.fa.fa-youtube-play.fa-lg'),
                            m.trust('&nbsp;'),
                            'Assista ao vídeo tutorial',
                            m('a.alt-link[href=\'https://catarse.attach.io/Hk5H9HKeZ\'][target=\'_blank\']')
                        ]
                    ),
                    m('.w-video.w-embed', { style: { 'padding-top': '56.17021276595745%' } },
                        m('iframe.embedly-embed[allowfullscreen=\'\'][frameborder=\'0\'][scrolling=\'no\'][src=\'//cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fwww.youtube.com%2Fembed%2FzglP9Pbu1uE%3Ffeature%3Doembed&url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DzglP9Pbu1uE&image=https%3A%2F%2Fi.ytimg.com%2Fvi%2FzglP9Pbu1uE%2Fhqdefault.jpg&key=96f1f04c5f4143bcb0f2e68c87d65feb&type=text%2Fhtml&schema=youtube\']')
                    )
                ]
            ),
            m('.card.u-radius',
                [
                    m('.fontsize-small.u-marginbottom-20',
                        [
                            m('span.fa.fa-lightbulb-o.fa-lg'),
                            m.trust('&nbsp;'),
                            'Dicas',
                            m('a.alt-link[href=\'https://catarse.attach.io/Hk5H9HKeZ\'][target=\'_blank\']')
                        ]
                    ),
                    m('ul.w-list-unstyled',
                        [
                            m('li.u-marginbottom-10',
                                m('a.fontsize-smaller.alt-link[href=\'https://suporte.catarse.me/hc/pt-br/articles/217916143-A-transfer%C3%AAncia-do-dinheiro#conta\'][target=\'_blank\']',
                                    'Responsável pelo projeto e Conta bancária para receber o dinheiro'
                                )
                            ),
                            m('li.u-marginbottom-10',
                                m('a.fontsize-smaller.alt-link[href=\'https://suporte.catarse.me/hc/pt-br/articles/115002214043-Responsabilidades-e-Seguran%C3%A7a?ref=ctrse_footer\'][target=\'_blank\']',
                                    'Responsabilidades e Segurança no Catarse'
                                )
                            )
                        ]
                    )
                ]
            )
        ]);
    }
}

export default userSettingsHelp;
