import m from 'mithril'
import prop from 'mithril/stream'
import mq from 'mithril-query'
import _ from 'underscore'
import h from '../../../src/h'
import { Modal } from '../../../src/shared/components/modal'

describe('Modal', () => {

    it('should close modal', () => {

        // 1. Arrange
        const onCloseControls = {
            onClose() { }
        }
        spyOn(onCloseControls, 'onClose')
        const component = mq(<Modal hideCloseButton={false} onClose={onCloseControls.onClose} ><div>CONTENT</div></Modal>)

        // 2. Act
        component.click('a',  new Event('click'))
        
        // 3. Assert
        expect(onCloseControls.onClose).toHaveBeenCalled()
    })
    
})