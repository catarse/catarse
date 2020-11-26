
import m from 'mithril';

const dashboardSubscriptionCardDetailUserAddress = {
    view: function({attrs})
    {
        return (attrs.user && attrs.user.address) ?
            m('.u-marginbottom-20.card.card-secondary.u-radius', [
                m('.fontsize-small.fontweight-semibold.u-marginbottom-10',
                    'Endereço'
                ),
                m('.fontsize-smaller', [
                    m('div', [attrs.user.address.street, attrs.user.address.street_number, attrs.user.address.complementary].join(', ')),
                    m('div', [attrs.user.address.city, attrs.user.address.state].join(' - ')),
                    m('div', `CEP: ${attrs.user.address.zipcode}`),
                    m('div', `${attrs.user.address.country}`)
                ])
            ]) : m('span', '');       
    }
};

export default dashboardSubscriptionCardDetailUserAddress;
