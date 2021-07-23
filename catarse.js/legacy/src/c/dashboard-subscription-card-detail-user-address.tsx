
import m from 'mithril'
import { withHooks } from 'mithril-hooks'
import { Address } from '../entities'
import { Loader } from '../shared/components/loader'


interface DashboardSubscriptionCardDetailUserAddressProps {
    user: {
        address: Address
    }
}

export const DashboardSubscriptionCardDetailUserAddress = withHooks<DashboardSubscriptionCardDetailUserAddressProps>(_DashboardSubscriptionCardDetailUserAddress)

function _DashboardSubscriptionCardDetailUserAddress({ user }: DashboardSubscriptionCardDetailUserAddressProps) {
    if (user?.address?.zipcode) {
        return (
            <div class="u-marginbottom-20 card card-secondary u-radius">
                <div class="fontsize-small fontweight-semibold u-marginbottom-10">
                    Endereço
                </div>
                <div class="fontsize-smaller">
                    {buildAddressLines(user.address).map(addressLine =>
                        (<div>{addressLine}</div>)
                    )}
                </div>
            </div>
        )
    } else {
        return <Loader />
    }
}

function buildAddressLines(address: Address) {
    let firstAddressLine = `${address.street}, ${address.street_number}`
    if (address.complementary) {
        firstAddressLine += `, ${address.complementary}`
    }
    firstAddressLine += ` - ${address.neighborhood}`;
    return [
        firstAddressLine,
        `${address.city} - ${address.state}`,
        `CEP: ${address.zipcode}`,
        `${address.country}`,
    ]
}
