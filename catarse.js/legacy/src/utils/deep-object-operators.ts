export function defineDeepObject(objectPath = '', value = null, previousObj = {}) {
    const obj = previousObj;
    defineDeepObjectRecursive(objectPath, obj, value);
    return obj;
}

function defineDeepObjectRecursive(objectPath = '', deepObject = {}, value = null) {
    if (typeof value !== 'undefined' && value !== null && value !== '') {
        const index = objectPath.indexOf('.');
        const hasDeeperPath = index >= 0;
        const currentKey = objectPath.slice(0, index > 0 ? index : objectPath.length);

        if (hasDeeperPath) {
            deepObject[currentKey] = deepObject[currentKey] || {}
            const remainingPath = objectPath.slice(index + 1, objectPath.length);
            defineDeepObjectRecursive(remainingPath, deepObject[currentKey], value);
        } else {
            deepObject[currentKey] = value;
        }
    }
}