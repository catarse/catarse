import m from 'mithril'

type DescriptionEditTipsAttrs = {
    show: boolean
}

export class DescriptionEditTips implements m.Component {
    view({ attrs } : m.Vnode<DescriptionEditTipsAttrs>) {

        const show = attrs.show

        return (
            <div class='dashboard-column-tips description' style={`display: ${show ? 'block' : 'none'}`}>
                <div class="card card-secondary">
                    <div>
                        <div class="arrow-left"></div>
                        <img src="https://s3.amazonaws.com/cdn.catarse/assets/rafa.png" alt="" class="thumb small u-round u-right" />
                        <div class="fontsize-smallest">
                            Dicas do Rafa, nosso especialista
                        </div>
                    </div>
                </div>
                <div class="card">
                    <div class="fontsize-smaller u-marginbottom-20">
                        Para alcançar o maior número de apoios:
                    </div>
                    <div class="fontsize-smaller u-marginbottom-10">
                        <span class="fa fa-check fa-fw" aria-hidden="true"></span> 
                        <span> Descreva quem irá se beneficiar</span>
                    </div>
                    <div class="fontsize-smaller u-marginbottom-10">
                        <span class="fa fa-check fa-fw" aria-hidden="true"></span>
                        <span> Dê detalhes de como o dinheiro será usado</span>
                    </div>
                    <div class="fontsize-smaller u-marginbottom-10">
                        <span class="fa fa-check fa-fw" aria-hidden="true"></span> 
                        <span> Explique a urgência da sua causa</span>
                    </div>
                    <div class="fontsize-smaller u-marginbottom-10">
                        <span class="fa fa-check fa-fw" aria-hidden="true"></span>
                        <span> Conte para as pessoas o que o suporte delas irá representar para você</span>
                    </div>
                    <div class="fontsize-smaller u-marginbottom-10">
                        <span class="fa fa-check fa-fw" aria-hidden="true"></span>
                        <span> Compartilhe o quão feliz você ficará com o apoio das pessoas</span>
                    </div>
                </div>
            </div>
        )
    }
}