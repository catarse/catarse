import { setCSRFHeaderFromMetaTags } from '../../../../../src/shared/services/infra/middlewares/set-csrf-header-from-meta-tags'

describe('middlewares', () => {
    describe('SetCSRFHeaderFromMetaTags', () => {
    
        const CSRF_TOKEN_HEADER = 'CSRF_TOKEN_HEADER'
        const CSRF_TOKEN_STRING = 'CSRF_TOKEN_STRING'
    
        beforeAll(() => {
            const tokenHeaderMeta = document.createElement('meta')
            tokenHeaderMeta.content = CSRF_TOKEN_HEADER
            tokenHeaderMeta.name = 'csrf-param'
    
            const tokenStringMeta = document.createElement('meta')
            tokenStringMeta.content = CSRF_TOKEN_STRING
            tokenStringMeta.name = 'csrf-token'
    
            document.head.appendChild(tokenHeaderMeta)
            document.head.appendChild(tokenStringMeta)
        })
    
        it('should set CSRF token on header', () => {
    
            // 1. arrange
            const headers = { }
    
            // 2. act
            setCSRFHeaderFromMetaTags('<none>', headers)
    
            // 3. assert
            expect(headers).toEqual(jasmine.objectContaining({
                'X-CSRF-Token': CSRF_TOKEN_STRING
            }))
        })
    })
})