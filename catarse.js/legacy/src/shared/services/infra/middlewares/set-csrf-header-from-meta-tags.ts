import { Middleware } from '../entities/middleware'
import { HttpHeaders } from '../entities'

export const setCSRFHeaderFromMetaTags : Middleware = (url : string, headers : HttpHeaders) => {
    const csrfTokenHeader = getCSRFTokenHeader()
    if (csrfTokenHeader) {
        headers['X-CSRF-Token'] = getCSRFTokenValue()
    }
}

function getCSRFTokenHeader() {
    const meta = document.querySelector('[name=csrf-param]')
    return meta ? meta.getAttribute('content') : null
}

function getCSRFTokenValue() {
    const meta = document.querySelector('[name=csrf-token]')
    return meta ? meta.getAttribute('content') : null
}