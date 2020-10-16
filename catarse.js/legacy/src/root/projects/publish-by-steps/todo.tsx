import m from 'mithril'

import './todo.css'

export class Todo implements m.Component {
    view({ attrs }) {
        return (
            <div class="section">
                <div class="w-container">
                    <div class="w-row">
                        <div class="w-col w-col-2"></div>
                        <div class="w-col w-col-8">
                            <div class="card medium card-terciary u-marginbottom-20">
                                <div class="title-dashboard">
                                    Sua campanha está no ar.
                                    <br />
                                    Vamos agora receber doações.
                                    <br />
                                </div>
                                <div class="w-row">
                                    <div class="w-col w-col-2"></div>
                                    <div class="w-col w-col-8">
                                        <ul role="list" class="list-dashboard">
                                            <li class="list-dashboard-item">
                                                <span class="fa fa-check-circle list-dashboard" aria-hidden="true"></span>
                                                Comece sua campanha
                                            </li>
                                            <li class="list-dashboard-item">
                                                Compartilhe com 3 a 5 amigos e peça para eles te ajudarem a divulgar
                                            </li>
                                            <li class="list-dashboard-item">
                                                Faça um post em pelo menos 1 rede social
                                            </li>
                                            <li class="list-dashboard-item">
                                                Envie lembretes para os seus amigos
                                            </li>
                                        </ul>
                                        <div class="card u-radius u-margintop-40 card-secondary">
                                            <div class="w-row">
                                                <div class="fal fa-hand-holding-usd fa-2x w-col w-col-2 u-marginbottom-10" aria-hidden="true"></div>
                                                <div class="w-col w-col-10">
                                                    <div>
                                                        Você poderá enviar as doações para sua conta bancária quando encerrar sua campanha.
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="w-col w-col-2"></div>
                                </div>
                                <div class="u-margintop-40 u-marginbottom-20 w-row">
                                    <div class="w-col w-col-2"></div>
                                    <div class="w-col w-col-8">
                                        <a href="#share" class="btn btn-large">
                                            Comece a compartilhar
                                        </a>
                                    </div>
                                    <div class="w-col w-col-2"></div>
                                </div>
                            </div>
                        </div>
                        <div class="w-col w-col-2"></div>
                    </div>
                </div>
            </div>
        )
    }
}