export type FieldMapper = {
    from(field : string): string
}

const FieldMapperIdentity : FieldMapper = {
    from: field => field
}

export class ErrorsViewModel {

    private errors : { [field:string] : string[] }

    constructor(private fieldMapper : FieldMapper = FieldMapperIdentity) {
        this.errors = {}
    }

    public hasError(field : string) : boolean {
        return this.getErrors(field).length > 0
    }

    public getErrors(field : string) : string[] {
        return (this.errors[field] || [])
    }

    public setErrors(errorsJson : string) {

        this.clearErrors()

        try {
            const parsedErrors = JSON.parse(errorsJson)
            Object.keys(parsedErrors).forEach(field => {
                const mappedField = this.fieldMapper.from(field)
                const errorMessages = parsedErrors[field]
                if (typeof errorMessages === 'string') {
                    this.setErrorOnField(mappedField, errorMessages)
                } else {
                    for (const message of errorMessages) {
                        this.setErrorOnField(mappedField, message)
                    }
                }
            })
        } catch(e) {
            this.clearErrors()
            console.log('Error: could not parse errosJson string', e.message)
        }
    }

    public clearErrors() {
        this.errors = {}
    }

    private setErrorOnField(field : string, message : string) {
        this.errors[field] = (this.errors[field] || []).concat(message)
    }
}