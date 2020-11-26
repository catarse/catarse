import m from 'mithril'

export class RewardsEditTips implements m.Component {
    view({ attrs }) {
        return (
            <div class="dashboard-column-tips">
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
                        Algumas dicas valiosas para a criação de recompensas:
                    </div>
                    <div class="fontsize-smaller u-marginbottom-10">
                        <span class="fa fa-check fa-fw" aria-hidden="true"></span>
                        &nbsp;Prefira sempre recompensas virtuais, como participação em grupos de discussão, mensagem de agradecimento, foto digital, etc
                    </div>
                    <div class="fontsize-smaller u-marginbottom-10">
                        <span class="fa fa-check fa-fw" aria-hidden="true"></span>
                        &nbsp;Tente não ultrapassar 5 a 7 recompensas ofertadas. Muitas opções podem causar confusão para seus apoiadores
                    </div>
                    <div class="fontsize-smaller u-marginbottom-10">
                        <span class="fa fa-check fa-fw" aria-hidden="true"></span>
                        &nbsp;Ofereça recompensas variadas, com valores justos e realistas. Um exemplo poderia ser R$10, R$30, R$50, R$100, R$500 e acima de R$1.000
                    </div>
                    <div class="fontsize-smaller u-marginbottom-10">
                        <span class="fa fa-check fa-fw" aria-hidden="true"></span>
                        &nbsp;Se for optar por oferecer recompensas físicas, tenha certeza de que o processo de produção e orçamento estão bem mapeados.  
                    </div>
                </div>
            </div>
        )
    }
}