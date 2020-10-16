import m from 'mithril'
import { UserInfoEditPublicProfileTips } from '../../../c/projects/publish-by-steps/user-info-edit-public-profile-tips'
import { UserInfoEditSettingsTips } from '../../../c/projects/publish-by-steps/user-info-edit-settings-tips'
import { UserInfoEditPublicProfile } from '../../../c/projects/publish-by-steps/user-info-edit-public-profile'
import { UserDetails } from '../../../@types/user-details'
import { UserInfoEditSettings } from '../../../c/projects/publish-by-steps/user-info-edit-settings'
import h from '../../../h'

export type UserInfoEditAttrs = {
    user: UserDetails
    save(profileImage? : File): Promise<boolean>
    isSaving: boolean
    hasErrorOn(field : string): boolean
    getErrorsOn(field : string): string[]
}

export type UserInfoEditState = {
    selectedProfileImageFile: File | null
}

export class UserInfoEdit implements m.Component {


    view({attrs, state} : m.Vnode<UserInfoEditAttrs, UserInfoEditState>) {
        const user = attrs.user
        const save = attrs.save
        const isSaving = attrs.isSaving
        const hasErrorOn = attrs.hasErrorOn
        const getErrorsOn = attrs.getErrorsOn

        return (
            <div class="section">
                <div class="w-container">
                    <div class="w-row">
                        <div class="w-col w-col-8">
                            <UserInfoEditPublicProfile 
                                user={user} 
                                hasErrorOn={hasErrorOn}
                                getErrorsOn={getErrorsOn}
                                onSelectProfileImage={(profileImageFile : File) => {
                                    state.selectedProfileImageFile = profileImageFile
                                }}/>
                        </div>
                        <div class="w-col w-col-4 w-hidden-small w-hidden-tiny">
                            <UserInfoEditPublicProfileTips />
                        </div>
                    </div>
                    <div class="w-row">
                        <div class="w-col w-col-8">
                            <div class="">
                                <UserInfoEditSettings 
                                    user={user}
                                    hasErrorOn={hasErrorOn}
                                    getErrorsOn={getErrorsOn} />
                                <div class="u-margintop-40 u-marginbottom-20 w-row">
                                    <div class="w-col w-col-2"></div>
                                    <div class="w-col w-col-8">
                                        {
                                            isSaving ?
                                                h.loader()
                                                :
                                                <a onclick={(event : Event) => {
                                                    save(state.selectedProfileImageFile)
                                                }} href="#user" class="btn btn-large">
                                                    Próximo &gt;
                                                </a>
                                        }
                                    </div>
                                    <div class="w-col w-col-2"></div>
                                </div>
                            </div>
                            <div class="u-text-center u-margintop-20 fontsize-smaller">
                                <a href="#ask-about-reward" class="link-hidden-dark">
                                    &lt; Voltar
                                </a>
                            </div>
                        </div>
                        <div class="w-col w-col-4  w-hidden-small w-hidden-tiny">
                            <UserInfoEditSettingsTips />
                        </div>
                    </div>
                </div>
            </div>
        )
    }
}