import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import h from '../h';
import models from '../models';
import landingSignup from '../c/landing-signup';
import projectRow from '../c/project-row';
import landingQA from '../c/landing-qa';

const Flex = {
    oninit: function(vnode) {
        const stats = prop([]),
            projects = prop([]),
            l = prop(),
            sample3 = _.partial(_.sample, _, 3),
            builder = {
                customAction: 'http://fazum.catarse.me/obrigado-landing-catarse-flex'
            },
            addDisqus = () => {
                h.discuss('https://catarse.me/flex', 'flex_page');
            },
            flexVM = catarse.filtersVM({
                mode: 'eq',
                state: 'eq',
                recommended: 'eq'
            }),
            statsLoader = catarse.loaderWithToken(models.statistic.getRowOptions());

        flexVM.mode('flex').state('online').recommended(true);

        const projectsLoader = catarse.loader(models.project.getPageOptions(flexVM.parameters()));

        statsLoader.load().then(stats);

        projectsLoader.load().then(_.compose(projects, sample3));

        vnode.state = {
            addDisqus,
            builder,
            statsLoader,
            stats,
            projectsLoader,
            projects: {
                loader: projectsLoader,
                collection: projects
            }
        };
    },
    view: function({state, attrs}) {
        const stats = _.first(state.stats());

        return [
            m('.w-section.hero-full.hero-zelo', [
                m('.w-container.u-text-center', [
                    m('img.logo-flex-home[src=\'/assets/logo-flex.png\'][width=\'359\']'),
                    m('.w-row', [
                        m('.w-col.fontsize-large.u-marginbottom-60.w-col-push-2.w-col-8', 'Vamos construir uma nova modalidade de crowdfunding! Cadastre seu email e saiba como inscrever o seu projeto no flex!')
                    ]),
                    m('.w-row', [
                        m('.w-col.w-col-2'),
                        m(landingSignup, {
                            builder: state.builder
                        }),
                        m('.w-col.w-col-2')
                    ])
                ])
            ]), [
                m('.section', [
                    m('.w-container', [
                        m('.fontsize-largest.u-margintop-40.u-text-center', 'Pra quem será?'), m('.fontsize-base.u-text-center.u-marginbottom-60', 'Iniciaremos a fase de testes com categorias de projetos específicas'), m('div', [
                            m('.w-row.u-marginbottom-60', [
                                m('.w-col.w-col-6', [
                                    m('.u-text-center.u-marginbottom-20', [
                                        m('img[src=\'https://daks2k3a4ib2z.cloudfront.net/54b440b85608e3f4389db387/560e393a01b66e250aca67cb_icon-zelo-com.png\'][width=\'210\']'), m('.fontsize-largest.lineheight-loose', 'Causas')
                                    ]), m('p.fontsize-base', 'Flexibilidade para causas de impacto! Estaremos abertos a campanhas de organizações ou pessoas físicas para arrecadação de recursos para causas pessoais, projetos assistenciais, saúde, ajudas humanitárias, proteção aos animais, empreendedorismo socioambiental, ativismo ou qualquer coisa que una as pessoas para fazer o bem.')
                                ]), m('.w-col.w-col-6', [
                                    m('.u-text-center.u-marginbottom-20', [
                                        m('img[src=\'https://daks2k3a4ib2z.cloudfront.net/54b440b85608e3f4389db387/560e3929a0daea230a5f12cd_icon-zelo-pessoal.png\'][width=\'210\']'), m('.fontsize-largest.lineheight-loose', 'Vaquinhas')
                                    ]), m('p.fontsize-base', 'Campanhas simples que precisam de flexibilidade para arrecadar dinheiro com pessoas próximas. Estaremos abertos a uma variedade de campanhas pessoais que podem ir desde cobrir custos de estudos a ajudar quem precisa de tratamento médico. De juntar a grana para fazer aquela festa a comprar presentes para alguém com a ajuda da galera. ')
                                ])
                            ])
                        ])
                    ])
                ]), m('.w-section.section.bg-greenlime.fontcolor-negative', [
                    m('.w-container', [
                        m('.fontsize-largest.u-margintop-40.u-marginbottom-60.u-text-center', 'Como funcionará?'), m('.w-row.u-marginbottom-40', [
                            m('.w-col.w-col-6', [
                                m('.u-text-center', [
                                    m('img[src=\'https://daks2k3a4ib2z.cloudfront.net/54b440b85608e3f4389db387/560e39c578b284493e2a428a_zelo-money.png\'][width=\'180\']')
                                ]), m('.fontsize-large.u-marginbottom-10.u-text-center.fontweight-semibold', 'Fique com quanto arrecadar'), m('p.u-text-center.fontsize-base', 'O flex é para impulsionar campanhas onde todo dinheiro é bem vindo! Você fica com tudo que conseguir arrecadar.')
                            ]), m('.w-col.w-col-6', [
                                m('.u-text-center', [
                                    m('img[src=\'https://daks2k3a4ib2z.cloudfront.net/54b440b85608e3f4389db387/560e39d37c013d4a3ee687d2_icon-reward.png\'][width=\'180\']')
                                ]), m('.fontsize-large.u-marginbottom-10.u-text-center.fontweight-semibold', 'Não precisa de recompensas'), m('p.u-text-center.fontsize-base', 'No flex oferecer recompensas é opcional. Você escolhe se oferecê-las faz sentido para o seu projeto e campanha.')
                            ])
                        ]), m('.w-row.u-marginbottom-40', [
                            m('.w-col.w-col-6', [
                                m('.u-text-center', [
                                    m('img[src=\'https://daks2k3a4ib2z.cloudfront.net/54b440b85608e3f4389db387/560e39fb01b66e250aca67e3_icon-curad.png\'][width=\'180\']')
                                ]), m('.fontsize-large.u-marginbottom-10.u-text-center.fontweight-semibold', 'Você mesmo publica seu projeto'), m('p.u-text-center.fontsize-base', 'Todos os projetos inscritos no flex entram no ar. Agilidade e facilidade para você captar recursos através da internet.')
                            ]), m('.w-col.w-col-6', [
                                m('.u-text-center', [
                                    m('img[src=\'https://daks2k3a4ib2z.cloudfront.net/54b440b85608e3f4389db387/560e39e77c013d4a3ee687d4_icon-time.png\'][width=\'180\']')
                                ]), m('.fontsize-large.u-marginbottom-10.u-text-center.fontweight-semibold', 'Encerre a campanha quando quiser'), m('p.u-text-center.fontsize-base', 'Não há limite de tempo de captação. Você escolhe  quando encerrar sua campanha e receber os valores arrecadados.')
                            ])
                        ])
                    ])
                ]),
                m('.w-section.section', [
                    m('.w-container', [
                        m('.w-editable.fontsize-larger.u-margintop-40.u-margin-bottom-40.u-text-center', 'Conheça alguns dos primeiros projetos flex'),
                        state.projectsLoader() ? h.loader() : m(
                            projectRow,
                            { collection: state.projects, ref: 'ctrse_flex', wrapper: '.w-row.u-margintop-40' }
                        )
                    ])
                ]),
                m('.w-section.divider'),
                m('.w-section.section', [
                    m('.w-container', [
                        m('.fontsize-larger.u-text-center.u-marginbottom-60.u-margintop-40', 'Dúvidas'), m('.w-row.u-marginbottom-60', [
                            m('.w-col.w-col-6', [
                                m(landingQA, {
                                    question: 'Quais são as taxas da modalidade flexível? ',
                                    answer: 'Como no Catarse, enviar um projeto não custa nada! A taxa cobrada no serviço Catarse flex é de 13% sobre o valor arrecadado.'
                                }),
                                m(landingQA, {
                                    question: 'De onde vem o dinheiro do meu projeto?',
                                    answer: 'Família, amigos, fãs e membros de comunidades que você faz parte são seus maiores colaboradores. São eles que irão divulgar sua campanha para as pessoas que eles conhecem, e assim o círculo de apoiadores vai aumentando e a sua campanha ganha força.'
                                }),
                                m(landingQA, {
                                    question: 'Qual a diferença entre o flexível e o "tudo ou nada"?',
                                    answer: 'Atualmente o Catarse utiliza apenas o modelo "tudo ou nada", onde você só fica com o dinheiro se bater a meta de arrecadação dentro do prazo da campanha. O modelo flexível é diferente pois permite que o realizador fique com o que arrecadar, independente de atingir ou não a meta do projeto no prazo da campanha. Não haverá limite de tempo para as campanhas. Nosso sistema flexível será algo novo em relação aos modelos que existem atualmente no mercado.'
                                }),
                            ]), m('.w-col.w-col-6', [
                                m(landingQA, {
                                    question: 'Posso inscrever projetos para a modalidade flexível já?',
                                    answer: 'Sim. Cadastre seu email e saiba como inscrever o seu projeto no flex!'
                                }),
                                m(landingQA, {
                                    question: 'Por quê vocês querem fazer o Catarse flex?',
                                    answer: 'Acreditamos que o ambiente do crowdfunding brasileiro ainda tem espaço para muitas ações, testes e experimentações para entender de fato o que as pessoas precisam. Sonhamos com tornar o financiamento coletivo um hábito no Brasil. O Catarse flex é mais um passo nessa direção.'
                                }),
                                m(landingQA, {
                                    question: 'Quando vocês irão lançar o Catarse flex?',
                                    answer: 'Ainda não sabemos quando abriremos o flex para o público em geral, mas você pode cadastrar seu email nessa página e receber um material especial de como inscrever seu projeto.'
                                })
                            ])
                        ])
                    ])
                ]),
                m('.w-section.section-large.u-text-center.bg-purple', [
                    m('.w-container.fontcolor-negative', [
                        m('.fontsize-largest', 'Inscreva seu projeto!'), m('.fontsize-base.u-marginbottom-60', 'Cadastre seu email e saiba como inscrever o seu projeto no flex!'), m('.w-row', [
                            m('.w-col.w-col-2'),
                            m(landingSignup, {
                                builder: state.builder
                            }),
                            m('.w-col.w-col-2')
                        ])
                    ])
                ]), m('.w-section.section-one-column.bg-catarse-zelo.section-large[style="min-height: 50vh;"]', [
                    m('.w-container.u-text-center', [
                        m('.w-editable.u-marginbottom-40.fontsize-larger.lineheight-tight.fontcolor-negative', 'O flex é um experimento e iniciativa do Catarse, maior plataforma de crowdfunding do Brasil.'),
                        m('.w-row.u-text-center', (state.statsLoader()) ? h.loader() : [
                            m('.w-col.w-col-4', [
                                m('.fontsize-jumbo.text-success.lineheight-loose', h.formatNumber(stats.total_contributors, 0, 3)), m('p.start-stats.fontsize-base.fontcolor-negative', 'Pessoas ja apoiaram pelo menos 01 projeto no Catarse')
                            ]),
                            m('.w-col.w-col-4', [
                                m('.fontsize-jumbo.text-success.lineheight-loose', h.formatNumber(stats.total_projects_success, 0, 3)), m('p.start-stats.fontsize-base.fontcolor-negative', 'Projetos ja foram financiados no Catarse')
                            ]),
                            m('.w-col.w-col-4', [
                                m('.fontsize-jumbo.text-success.lineheight-loose', `${stats.total_contributed.toString().slice(0, 2)} milhões`), m('p.start-stats.fontsize-base.fontcolor-negative', 'Foram investidos em ideias publicadas no Catarse')
                            ])
                        ])
                    ])
                ]),
                m('.w-section.section.bg-blue-one.fontcolor-negative', [
                    m('.w-container', [
                        m('.fontsize-large.u-text-center.u-marginbottom-20', 'Recomende o Catarse flex para amigos! '),
                        m('.w-row', [
                            m('.w-col.w-col-2'),
                            m('.w-col.w-col-8', [
                                m('.w-row', [
                                    m('.w-col.w-col-6.w-col-small-6.w-col-tiny-6.w-sub-col-middle', [
                                        m('div', [
                                            m('img.icon-share-mobile[src=\'https://daks2k3a4ib2z.cloudfront.net/54b440b85608e3f4389db387/53a3f66e05eb6144171d8edb_facebook-xxl.png\']'),
                                            m(`a.w-button.btn.btn-large.btn-fb[href="http://www.facebook.com/sharer/sharer.php?u=https://www.catarse.me/flex?ref=facebook&title=${encodeURIComponent('Conheça o novo Catarse Flex!')}"][target="_blank"]`, 'Compartilhar')
                                        ])
                                    ]),
                                    m('.w-col.w-col-6.w-col-small-6.w-col-tiny-6', [
                                        m('div', [
                                            m('img.icon-share-mobile[src=\'https://daks2k3a4ib2z.cloudfront.net/54b440b85608e3f4389db387/53a3f65105eb6144171d8eda_twitter-256.png\']'),
                                            m(`a.w-button.btn.btn-large.btn-tweet[href="https://twitter.com/intent/tweet?text=${encodeURIComponent('Vamos construir uma nova modalidade de crowdfunding para o Catarse! Junte-se a nós, inscreva seu email!')}https://www.catarse.me/flex?ref=twitter"][target="_blank"]`, 'Tuitar')
                                        ])
                                    ])
                                ])
                            ]),
                            m('.w-col.w-col-2')
                        ])
                    ])
                ]), m('.w-section.section-large.bg-greenlime', [
                    m('.w-container', [
                        m('#participe-do-debate.u-text-center', { oncreate: h.toAnchor() }, [
                            m('h1.fontsize-largest.fontcolor-negative', 'Construa o flex conosco'), m('.fontsize-base.u-marginbottom-60.fontcolor-negative', 'Inicie uma conversa, pergunte, comente, critique e faça sugestões!')
                        ]),
                        m('#disqus_thread.card.u-radius[style="min-height: 50vh;"]', {
                            oncreate: state.addDisqus
                        })
                    ])
                ])
            ]
        ];
    }
};

export default Flex;
