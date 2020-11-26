export async function waitFor(ms : number) {
    const ref = { current : null }
    const execute = (resolve) => { ref.current = resolve }
    const promise = new Promise(execute)
    setTimeout(() => { ref.current() }, ms)
    return promise
}