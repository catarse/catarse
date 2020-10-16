import m from 'mithril'
import { UserDetails } from '../@types/user-details'
import h from '../h'
import userVM from './user-vm'
import { RailsErrors } from '../@types/rails-errors'
import _ from 'underscore'
import { Subject, Observable } from 'rxjs'
import { ThisWindow, I18ScopeType } from '../@types/window'

declare var window : ThisWindow
const I18nScope = _.partial(h.i18nScope, 'activerecord.errors.models') as (params? : {}) => I18ScopeType;

export type FieldError = {
    field: string
    messages: string[]
}

type PublicProfileImageResponse = {
    cover_image: string | null
    uploaded_image: string | null
}

export class UserInfoEditViewModel {

    private _isLoading : boolean
    private _isSaving : boolean
    private _user : UserDetails
    private _errors : { [field:string] : string[] }
    private _errorObserver : Subject<FieldError>

    constructor(private project_id : number, private user_id : number) {
        this._isLoading = true
        this._isSaving = false
        this._errors = {}
        this._errorObserver = new Subject<FieldError>()
        this.fetchUser()
    }

    get isLoading() {
        return this._isLoading
    }

    get isSaving() {
        return this._isSaving
    }

    get user() : UserDetails {
        return this._user
    }

    get error() : Observable<FieldError> {
        return this._errorObserver
    }
    
    getErrors(field : string) : string[] {
        return this._errors[field] || []
    }

    hasErrorOn(field : string) : boolean {
        const errors = this._errors[field] || []
        return errors.length > 0
    }

    async save(profileImage? : File) : Promise<boolean> {
        
        try {
            this.clearErrors()
            this._isSaving = true
            h.redraw()

            if (profileImage) {
                await this.uploadImage(profileImage)
            }

            const userSaveAttributes = {
                public_name: this._user.public_name,
                links_attributes: this._user.links,
                cpf: this._user.owner_document,
                name: this._user.name,
                address_attributes: this._user.address,
                account_type: this._user.account_type,
                birth_date: this._user.birth_date,
                state_inscription: this._user.state_inscription,
                publishing_user_settings: true
            }

            const requiredFields = [
                'public_name',
                'account_type', 
                'name',
                'cpf',
                'birth_date',
            ]

            let hasEmptyField = false

            requiredFields.forEach(field => {
                if (_.isEmpty(userSaveAttributes[field])) {
                    this.setErrorOnField(field, this.blankError(field))
                    hasEmptyField = true
                }
            })

            if (hasEmptyField) {
                console.log(this._errors)
                return false
            }

            await this.trySaveUserAttributesAndValidatePublishProject(userSaveAttributes)
            return true
        } catch(e) {
            this.mapRailsErrors(e as RailsErrors)
            return false
        } finally {
            this.tryDispatchErrorDisplay()
            this._isSaving = false
            h.redraw()
        }
    }

    private tryDispatchErrorDisplay() {
        if (this.hasError()) {
            for (const field of Object.keys(this._errors)) {
                this._errorObserver.next({ field, messages: this._errors[field] })
                return
            }
        }
    }

    private hasError() {
        return Object.keys(this._errors).length > 0
    }

    private async uploadImage(profileImage : File) {
        const formData = new FormData()
        formData.append('uploaded_image', profileImage)

        try {
            const requestConfig = {
                method: 'POST',
                url: `/users/${this.user.id}/upload_image.json`,
                data: formData,
                config: h.setCsrfToken,
                serialize(data) {
                    return data;
                }
            }

            const response : PublicProfileImageResponse = await m.request(requestConfig)
            this._user.profile_img_thumbnail = response.uploaded_image
            return true
        } catch(e) {
            throw e
        }
    }

    private async fetchUser() {
        try {
            this._isLoading = true
            h.redraw()
            const response : UserDetails[] = await userVM.fetchUser(this.user_id, false)
            this._user = response[0]
        } catch(e) {
            //TODO: handle errors
        } finally {
            this._isLoading = false
            h.redraw()
        }
    }

    private async trySaveUserAttributesAndValidatePublishProject(userAttributes : any) {
        const saveRequestConfig = {
            method: 'PUT',
            url: `/users/${this.user_id}.json`,
            data: {
                user: userAttributes
            },
            config: h.setCsrfToken
        }

        const validatePublishRequestConfig = {
            method: 'GET',
            url: `/projects/${this.project_id}/validate_publish`,
            config: h.setCsrfToken
        }

        const address_state = this.blankError('address_state')
        const hasStateError = this._user.address.state_id === 0 || _.isEmpty(this._user.address.address_state)
        let hasThrown = false

        if (hasStateError) {
            delete userAttributes.address_attributes['state_id']
            delete userAttributes.address_attributes['address_state']
        }

        try {
            await m.request(saveRequestConfig)
            await m.request(validatePublishRequestConfig)
            if (hasStateError) {
                const errors = {
                    errors: [address_state],
                    errors_json: JSON.stringify({ address_state })
                }
                hasThrown = true
                throw errors
            }
        } catch(error) {
            const railsErrors = error as RailsErrors
            if (hasStateError && !hasThrown) {
                let errors_json = { address_state }
                let errors = []

                try {
                    errors_json = JSON.parse(railsErrors.errors_json)
                    errors_json.address_state = address_state
                    errors = (railsErrors.errors instanceof Array && railsErrors.errors) || []
                } catch(e) {
                    errors_json = { address_state }
                    errors = []
                }

                throw {
                    errors: errors.concat([address_state]),
                    errors_json: JSON.stringify(errors_json),
                }
            } else {
                throw railsErrors
            }
        }

    }

    private mapRailsErrors(error : RailsErrors) {
        const railsErrorJson = JSON.parse(error.errors_json)
        Object.keys(railsErrorJson).forEach(field => {
            if (typeof railsErrorJson[field] === 'string') {
                this.setErrorOnField(field, railsErrorJson[field])
            } else {
                for (const message of railsErrorJson[field]) {
                    this.setErrorOnField(field, message)
                }
            }
        })
    }

    private setErrorOnField(field : string, message : string) {
        this._errors[field] = (this._errors[field] || []).concat(message)
    }
    
    private clearErrors() {
        this._errors = {}
    }

    private blankError(field : string) {
        return window.I18n.t(`user.attributes.${field}.blank`, I18nScope())
    }

}