import m from 'mithril'

export class UserInfoEditPublicProfileTips implements m.Component {
    view({ attrs }) {
        return (
            <div class="dashboard-column-tips internet">
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
                    Apoiadores querem conhecer melhor quem está por trás do projeto. Links que ajudam a contar sua história são sempre bem vindos (seu site, perfis em mídias sociais, alguma matéria legal sobre você, uma entrevista). Procure informar no máximo 3 links, para ficar sucinto!
                    </div>
                    </div>
                </div>
        )
    }
}