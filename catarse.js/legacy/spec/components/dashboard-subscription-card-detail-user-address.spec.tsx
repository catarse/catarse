import mq from 'mithril-query'
import { DashboardSubscriptionCardDetailUserAddress } from "../../src/c/dashboard-subscription-card-detail-user-address"
import { Address } from "../../src/entities"

describe('DashboardSubscriptionCardDetailsUserAddress', () => {

    const fullAddress: Address = {
        street: 'STREET',
        street_number: 'STREET_NUMBER',
        complementary: 'COMPLEMENTARY',
        neighborhood: 'NEIGHBORHOOD',
        city: 'CITY',
        state: 'STATE',
        zipcode: 'ZIPCODE',
        country: 'COUNTRY',
    }

    const partialAddress = {
        street: 'STREET',
        street_number: 'STREET_NUMBER',
        complementary: 'COMPLEMENTARY',
        neighborhood: 'NEIGHBORHOOD',
        city: 'CITY',
        state: 'STATE',
        country: 'COUNTRY',
    }

    it('should present full user address', () => {
        // given
        const userData = { address: fullAddress }

        // when
        const component = mq(<DashboardSubscriptionCardDetailUserAddress user={userData}/>)

        // then
        for (const addressValue of Object.values(fullAddress)) {
            component.should.have(`.u-marginbottom-20.card.card-secondary.u-radius > .fontsize-smaller > div:contains(${addressValue})`)
        }
    })

    it('should present loader when user data is undefined', () => {
        // given
        const userData = undefined

        // when
        const component = mq(<DashboardSubscriptionCardDetailUserAddress user={userData}/>)

        // then
        component.should.have('img[alt="Loader"]')
    })

    it('should present loader when zipcode is not present', () => {
        // given
        const userData = { address: partialAddress as Address }

        // when
        const component = mq(<DashboardSubscriptionCardDetailUserAddress user={userData}/>)

        // then
        component.should.have('img[alt="Loader"]')
    })
})
