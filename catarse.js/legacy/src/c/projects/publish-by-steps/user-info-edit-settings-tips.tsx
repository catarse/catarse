import m from 'mithril'

export class UserInfoEditSettingsTips implements m.Component {
    view({attrs}) {
        return (
            <div class="dashboard-column-tips admin">
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
                    <div class="fontsize-smallest">
                        Os dados do responsável pelo projeto precisam ser os mesmos dados do dono da conta bancária que irá receber o dinheiro arrecadado. Esses dados não podem ser alterados após a publicação do projeto!
                    </div>
                </div>
            </div>
        )
    }
}