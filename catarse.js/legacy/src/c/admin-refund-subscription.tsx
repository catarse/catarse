import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import { I18nText } from '../shared/components/i18n-text';
import { ThisWindow } from '../entities';

declare var window : ThisWindow

const I18nScope = _.partial(h.i18nScope, 'admin.refund_subscriptions.view');

const adminRefundSubscription = {
    oninit: function(vnode) {
        let payment = vnode.attrs.payment,
            data = {};

        let builder = { requestOptions: {
                        url: (`admin/subscription_payments/refund`),
                        method: 'POST'}
                    };

        const load = () => m.request(_.extend({}, { data }, builder.requestOptions)),
              resp = h.RedrawStream('');

        builder.requestOptions.config = (xhr) => {
            if (h.authenticityToken()) {
                xhr.setRequestHeader('X-CSRF-Token', h.authenticityToken());
            }
        };

        const requestSuccess = (res) => {
            resp(res.success);
        };

        const requestError = (err) => {
            resp(err.errors[0]);
        };

        const submit = (e) => {
            e.target.disabled = true;
            e.target.innerHTML = window.I18n.t('wait', I18nScope());
            data['refund_payment'] = { ['payment_common_id'] : payment.id };
            load().then(requestSuccess, requestError);
            return false;
        };

        const unload = () => {
            resp('');
        };

        vnode.state = {
            toggler: h.toggleProp(false, true),
            submit,
            resp,
            unload,
        };

    },
    view: function({state, attrs}) {
        return (
            <span>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <span class="alt-link" style="cursor: pointer" onclick={state.toggler.toggle}>
                    <i class="fa fa-undo"></i>&nbsp;
                    <I18nText scope="admin.refund_subscriptions.view.refund"/>
                </span>
                {state.toggler() &&
                    <div class='dropdown-list card u-radius dropdown-list-medium zindex-10' onremove={state.unload}>
                        { state.resp() ?
                            <div name="response-refund-box">
                                <div class="w-row">
                                    <div class="w-col w-col-12">
                                        { state.resp() }
                                    </div>
                                </div>
                                <div class="w-row">
                                    <div class="w-col w-col-12">
                                        <button class="btn btn-small btn-terciary" onclick={state.toggler.toggle}>
                                            <I18nText scope="admin.refund_subscriptions.view.close"/>
                                        </button>
                                    </div>
                                </div>
                            </div>

                        :
                            <div name="confirmation-refund-box">
                                <div class="w-row">
                                    <div class="w-col w-col-12">
                                        <I18nText scope="admin.refund_subscriptions.view.confirm"/>
                                    </div>
                                </div>
                                <div class="w-row">
                                    <div class="w-col w-col-5">
                                        <form class='w-form' onsubmit={(event : Event) => event.preventDefault()}>
                                            <button onclick={state.submit} class="btn btn-small">
                                                <I18nText scope="admin.refund_subscriptions.view.positive"/>
                                            </button>
                                        </form>
                                    </div>
                                    <div class="w-col w-col-offset-1 w-col-6">
                                        <button class="btn btn-small btn-terciary" onclick={state.toggler.toggle}>
                                            <I18nText scope="admin.refund_subscriptions.view.negative"/>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        }
                    </div>
                }
            </span>
        )
    }
};

export default adminRefundSubscription;
