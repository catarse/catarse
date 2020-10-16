import m from 'mithril'
import mq from 'mithril-query'
import { Wrap } from '../../src/wrap'
import userVM from '../../src/vms/user-vm'
import '../lib/mocks/user-details.mock'

describe('Wrap', () => {
    describe('view', () => {        

        beforeAll(() => {
            window.optimizeObserver = {
                addListener() { }
            }
        })

        it('should display component after user is loaded', async () => {
            // 1. arrange
            const userMocked = UserDetailMockery()[0]
            const user_id = userMocked.id
            jasmine.Ajax
                .stubRequest(`${apiPrefix}/user_details`)
                .andReturn({
                    responseText: `[{"id":${user_id},"name":"User Name"}]`,
                })

            const component = mq(Wrap(TestComponent, { user_id }))

            // this is a hack to wait inner promises to resolve
            await sleep(0)
            component.redraw()
            // this is a hack to wait redraw execute after promises be resolved
            await sleep(0)

            // 2. act
            
            // 3. assert
            component.should.contain('INNER COMPONENT CONTENT')
        })

        it('should not display component before user is loaded', async () => {
            // 1. arrange
            const userMocked = UserDetailMockery()[0]
            const user_id = userMocked.id
            jasmine.Ajax
                .stubRequest(`${apiPrefix}/user_details`)
                .andReturn({
                    responseText: `[{"id":${user_id},"name":"User Name"}]`,
                })

            const component = mq(Wrap(TestComponent, { user_id }))

            // 2. act
            
            // 3. assert
            component.should.not.contain('INNER COMPONENT CONTENT')
        })

        function sleep(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }
    
    })
})

class TestComponent implements m.Component<{}> {
    view() {
        return (
            <div id='inner-component'>INNER COMPONENT CONTENT</div>
        )
    }
}