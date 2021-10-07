export function cleanUndefinedFromObject(obj: Object): Object {
    if (obj && typeof obj === 'object') {
        for (const [key, value] of Object.entries(obj)) {
            if (value === undefined) {
                delete obj[key]
            } else if (typeof value === 'object') {
                cleanUndefinedFromObject(value)
            }
        }
    }

    return obj
}
