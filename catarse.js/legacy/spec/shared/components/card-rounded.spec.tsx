// import { } from 'jasmine'

import { CardRounded } from '../../../src/shared/components/card-rounded'
import mq from 'mithril-query'

describe('CardRounded', () => {
    describe('view', () => {
        it('should render className, style and children', () => {
            const CHILDREN_TEXT = 'CHILDREN_TEXT'
            const container = mq(
                <CardRounded className='card-alert' style='background-color:red;'>
                    {CHILDREN_TEXT}
                </CardRounded>
            )
            container.should.have('.card-alert')
            container.should.contain(CHILDREN_TEXT)
            container.should.have('div[style="background-color:red;"]')
        })
    })
})