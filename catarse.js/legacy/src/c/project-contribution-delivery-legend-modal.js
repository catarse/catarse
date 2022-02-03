import m from 'mithril';
import h from '../h';

const ProjectContributionDeliveryLegendModal = {
    view: function() {
        return m('div', [
            m('.modal-dialog-header', [
                m('.fontsize-large.u-text-center',
                    'Status da entrega')
            ]),
            m('.modal-dialog-content', [
                m('.fontsize-smaller.u-marginbottom-30',
                    'Todo apoio tem, por padrão, o status de entrega \'Não enviada\'. Para ajudar no seu controle da entrega de recompensas, você pode alterar esses status e filtrar a pesquisa de apoios com os seguintes rótulos:'
                ),
                m('.u-marginbottom-20', [
                    m('.fontsize-smaller.fontweight-semibold', [
                        'Não enviada',
                        m.trust('&nbsp;')
                    ]),
                    m('.fontsize-smaller',
                        'Você ainda não enviou a recompensa para o apoiador.'
                    )
                ]),
                m('div',
                    m('span.fontsize-smaller.badge.badge-success',
                        'Enviada'
                    )
                ),
                m('.u-marginbottom-20',
                    m('.fontsize-smaller',
                        'Você já enviou a recompensa para o apoiador.'
                    )
                ),
                m('.u-marginbottom-20', [
                    m('div',
                        m('span.fontsize-smaller.badge.badge-attention',
                            'Erro no envio'
                        )
                    ),
                    m('.fontsize-smaller',
                        'Você enviou a recompensa, mas houve algum problema com o envio (ex: endereço incorreto).'
                    )
                ]),
                m('.u-marginbottom-20', [
                    m('div',
                        m('span.fontsize-smaller.badge.badge-success', [
                            m('span.fa.fa-check-circle',
                                ''
                            ),
                            ' Recebida'
                        ])
                    ),
                    m('.fontsize-smaller',
                        'O apoiador marcou a recompensa como \'Recebida\' no seu painel de controle \o/'
                    )
                ])
            ]),
            m('.divider.u-marginbottom-10'),
            m('.fontcolor-secondary.fontsize-smaller.u-marginbottom-30', [
                'Obs: mesmo que a recompensa não seja física (como uma cópia digital, por exemplo), você pode mesmo assim usar o sistema acima!'
            ])
        ]);
    }
};

export default ProjectContributionDeliveryLegendModal;
