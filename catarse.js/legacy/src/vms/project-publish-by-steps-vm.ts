import { Subject, Observable } from 'rxjs'
import m from 'mithril'
import { catarse } from '../api'
import models from '../models'
import { ProjectDetails } from "../@types/project-details"
import h from '../h'
import { RailsErrors } from '../@types/rails-errors'
import _ from 'underscore'
import { ThisWindow, I18ScopeType } from '../@types/window'

declare var window : ThisWindow

const I18nScope = _.partial(h.i18nScope, 'activerecord.errors.models') as (params : {}) => I18ScopeType;

export type FieldError = {
    field: string
    messages: string[]
}

export class ProjectPublishByStepsVM {
    private _project : ProjectDetails | null
    private _isLoadingProject : boolean
    private _isSavingProject : boolean
    private _errors : { [key:string] : string[] }
    private _errorObserver : Subject<FieldError>

    constructor(private project_id : number) {
        this._project = null
        this._isLoadingProject = true
        this._errors = {}
        this._errorObserver = new Subject<FieldError>()
        this.init()
    }

    get project() : ProjectDetails {
        const self = this
        return {
            ...this._project,
            get project_id() {
                return self._project.project_id
            },
            set project_id(value) {
                // won't set project_id
            },
            set headline(value) {
                self._project.headline = value
            },
            get headline() {
                return self._project.headline
            },
            set large_image(value) {
                self._project.large_image = value
            },
            get large_image() {
                return self._project.large_image
            },
            get video_url() {
                return self._project.video_url
            },
            set video_url(value) {
                self._project.video_url = value
            },
            get goal() {
                return self._project.goal
            },
            set goal(value) {
                self._project.goal = value
            },
            get about_html() {
                return self._project.about_html || ''
            },
            set about_html(value) {
                self._project.about_html = value
            },
            get permalink() {
                return self._project.permalink
            },
            set permalink(value) {
                self._project.permalink = value
            },
            get city_id() {
                return self._project.city_id
            },
            set city_id(value) {
                self._project.city_id = value
            }
        }
    }
    
    get isLoadingProject() : boolean {
        return this._isLoadingProject
    }

    get isSaving() : boolean {
        return this._isSavingProject
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

    async publish() {
        try {
            this._isSavingProject = true
            this._isLoadingProject = true
            const configPublishRequest = {
                method: 'GET',
                url: `/projects/${this.project_id}/push_to_online`,
                config: h.setCsrfToken
            }
            await m.request(configPublishRequest)
        } catch(e) {

        } finally {
            this._isSavingProject = false
            this._isLoadingProject = false
        }
    }
    
    async save(fields : string[], requiredFields : string[], cardImageFile? : File | undefined) {
        try {
            this.clearErrors()
            this._isSavingProject = true

            h.redraw()

            this._project.content_rating = 1
            this._project.budget = '.'
            fields.push('content_rating')
            fields.push('budget')

            const projectHasImageUploaded = !_.isEmpty(this._project.small_image) || !_.isEmpty(this._project.thumb_image)
            let someInvalidation = projectHasImageUploaded
            if ((requiredFields.includes('uploaded_image') && !projectHasImageUploaded) || typeof cardImageFile !== 'undefined') {
                someInvalidation = await this.uploadCardImage(cardImageFile)
                this._project.thumb_image = this._project.small_image = this._project.large_image
            }
            const requiredFieldsWithoutUploadedImage = requiredFields.filter(rf => rf !== 'uploaded_image')
            return (await this.saveFields(fields, requiredFieldsWithoutUploadedImage)) && someInvalidation
        } catch(e) {
            return false
        } finally {
            this.tryDispatchErrorDisplay()
            this._isSavingProject = false
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

    private async saveFields(fields : string[], requiredFields : string[]) {
        
        this._isSavingProject = true
        
        h.redraw()

        const projectDataToSave = {}
        for (const field of fields) {
            projectDataToSave[field] = this._project[field]
        }

        let manualErrorsSet = false

        for (const field of requiredFields) {
            if (!projectDataToSave[field]) {
                this.setErrorOnField(field, this.conditionalI18n(`${field}.blank`))
                manualErrorsSet = true
            }
        }

        if (manualErrorsSet) {
            h.redraw()
            return false
        }

        const requestOptions = {
            method: 'PUT',
            url: `/projects/${this.project_id}.json`,
            data: { project: projectDataToSave },
            config: h.setCsrfToken,
        }

        try {
            await m.request(requestOptions)
            return true
        } catch(error) {
            this.mapRailsErrors(error as RailsErrors)
            return false
        } finally {
            this._isSavingProject = false
            h.redraw()
        }        
    }

    private async uploadCardImage(coverImageFile : File | null) : Promise<boolean> {
        if (!coverImageFile) {
            this.setErrorOnField('uploaded_image', this.conditionalI18n('uploaded_image.blank'))
            return false
        } else {
            const data = new FormData()
            data.append('uploaded_image', coverImageFile)
            const requestOptions = {
                method: 'POST',
                url: `/projects/${this.project_id}/upload_image.json`,
                data,
                config: h.setCsrfToken,
            }
            await m.request(requestOptions)
            return true
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

    private async init() {
        this._project = await this.fetchProject()
    }

    private async fetchProject() {
        try {
            this._isLoadingProject = true
            const filter = catarse.filtersVM({ project_id: 'eq' }).project_id(this.project_id)
            const getRowParamenters = models.projectDetail.getRowOptions(filter.parameters())
            return (await catarse.loaderWithToken(getRowParamenters).load())[0]
        } catch(e) {
            throw e
        } finally {
            this._isLoadingProject = false
            h.redraw()
        }
    }

    private conditionalI18n(path : string, params = {}) {
        if (this._project.mode === 'flex') {
            return window.I18n.t(`flexible_project.attributes.${path}`, I18nScope(params))
        } else {
            return window.I18n.t(`project.attributes.${path}`, I18nScope(params))
        }
    }
}