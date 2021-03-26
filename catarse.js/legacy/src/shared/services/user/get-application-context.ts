export function getApplicationContext() {
    const context = {
        application: {},
        body: {},
    }

    const application = document.getElementById('application')
    if (application) {
        for (const attribute of application.attributes) {
            context.application[attribute.name] = attribute.value
        }
    }

    if (document.body) {
        for (const attribute of document.body.attributes) {
            context.body[attribute.name] = attribute.value
        }
    }

    return context
}
