import h from '../../../h'
import { getApplicationContext } from './get-application-context'

type ObjectWithFields<FieldType> = {
    [key:string]: FieldType
}

export function tryAccessPropertyValue<ReturnType = string>(objectName: string, objectToAccess: ObjectWithFields<ReturnType> | null, propertyName: string): ReturnType | null {
    if (!objectToAccess) {
        const errorStack = new Error().stack
        const context = {
            message: `No data for "${objectName}"`,
            stack: errorStack,
            context: getApplicationContext(),
            field_to_access: propertyName,
        }
        console.error(errorStack)
        h.captureMessage(JSON.stringify(context))
        return null
    }

    if (objectToAccess) {
        if (propertyName in objectToAccess) {
            return objectToAccess[propertyName]
        } else {
            return null
        }
    } else {
        return null
    }
}
