import m from 'mithril'
import { UserDetails } from '../../../@types/user-details'
import { InputImageFile } from '../../std/input-image-file'
import { Event } from '../../../@types/event-target'
import { InlineErrors } from '../../inline-errors'

export type UserInfoEditPublicProfileAttrs = {
    hasErrorOn(field : string)
    getErrorsOn(field : string): string[]
    user: UserDetails
    onSelectProfileImage(profileImageFile : File): void
}

export type UserInfoEditPublicProfileState = {
    selectedProfileImageFile: File | null
    imageBlobUrl: string
}

export class UserInfoEditPublicProfile implements m.Component {
    view({ attrs, state } : m.Vnode<UserInfoEditPublicProfileAttrs, UserInfoEditPublicProfileState>) {
        const user = attrs.user
        const hasErrorOn = attrs.hasErrorOn
        const getErrorsOn = attrs.getErrorsOn
        const onSelectProfileImage = attrs.onSelectProfileImage
        const profileImageUrl = state.imageBlobUrl || user.profile_img_thumbnail
        const onClickToAddNewLink = (event : Event) => {
            const links = user.links || []
            user.links = links
            const newLink = { link: '' }
            links.push(newLink as any)
        }
        const onClickRemoveLink = (link : { id: number, link: string }, index : number) => {
            if (link.id > 0) {
                link['invisible'] = true
                link['_destroy'] = 1
            } else {
                user.links.splice(index, 1)
            }
        }

        return (
            <div class="card medium card-terciary u-marginbottom-20">
                <div class="title-dashboard">
                    Agora fale sobre você
                </div>
                <div class="w-form">
                    <form id="public-profile-form-id">
                        <div class="u-marginbottom-30 w-row">
                            <div class="_w-sub-col w-col w-col-5">
                                <label for="name-11" class="fontweight-semibold fontsize-base">
                                    Nome público
                                </label>
                                <label for="name-11" class="field-label fontsize-smallest fontcolor-secondary">
                                    Esse é o nome que os usuários irão ver no seu perfil
                                </label>
                            </div>
                            <div class="w-col w-col-7">
                                <input 
                                    oninput={(event : Event) => user.public_name = event.target.value} 
                                    value={user.public_name} 
                                    type='text'
                                    id='public-name-id'
                                    name='public-name'
                                    class={`text-field positive w-input ${hasErrorOn('public_name') ? 'error' : ''}`} />
                                <InlineErrors messages={getErrorsOn('public_name')} />
                            </div>
                        </div>
                        <div class="u-marginbottom-20 w-row">
                            <div class="_w-sub-col w-col w-col-5">
                                <label for="name-11" class="fontweight-semibold fontsize-base">
                                    Imagem do perfil&nbsp;
                                    <span class="fontcolor-terciary">
                                        (opcional)
                                    </span>
                                </label>
                                <label for="name-11" class="field-label fontsize-smallest fontcolor-secondary">
                                    Essa imagem será utilizada como a miniatura de seu perfil (PNG, JPG)
                                </label>
                            </div>
                            <div class="_w-sub-col w-col w-col-4">
                                <InputImageFile 
                                    oninput={(event : Event<HTMLInputElement> ) => {
                                        if (event.target.files && event.target.files.length > 0) {
                                            state.selectedProfileImageFile = event.target.files[0]
                                            onSelectProfileImage(state.selectedProfileImageFile)

                                            if (profileImageUrl && profileImageUrl.indexOf('blob') >= 0) {
                                                URL.revokeObjectURL(profileImageUrl)
                                            }

                                            state.imageBlobUrl = URL.createObjectURL(state.selectedProfileImageFile)
                                        }
                                    }}
                                    class='btn btn-small btn-dark' >
                                    Escolher arquivo
                                </InputImageFile>
                                {
                                    profileImageUrl && profileImageUrl.length &&
                                    <div class="input file optional user_uploaded_image field_with_hint">
                                        <img alt="Avatar do Usuario" src={profileImageUrl} />
                                    </div>
                                }
                            </div>
                            <div class="w-col w-col-3">
                                <div class="fontsize-smallest fontcolor-secondary" style='padding-left: 4px;'>
                                    {
                                        state.selectedProfileImageFile ?
                                            state.selectedProfileImageFile.name
                                            :
                                            'Nenhum arquivo escolhido'
                                    }
                                </div>
                            </div>
                        </div>
                        <div class="u-marginbottom-10 w-row">
                            <div class="_w-sub-col w-col w-col-5">
                                <label for="name-11" class="fontweight-semibold field-label">
                                    Presença na internet&nbsp;
                                    <span class="fontcolor-terciary">
                                        (opcional)
                                    </span>
                                </label>
                                <label for="name-11" class="field-label fontsize-smallest fontcolor-secondary">
                                    Inclua links que ajudem apoiadores a te conhecer melhor.
                                    <br />
                                </label>
                            </div>
                            <div class="w-col w-col-7">
                                {
                                    user.links && user.links.filter(l => !l['invisible']).map((link, index) => (
                                        <div class="w-row">
                                            <div class="_w-sub-col-middle w-col w-col-10 w-col-small-10 w-col-tiny-10">
                                                <input value={link.link} oninput={(event:Event) => link.link = event.target.value} type="text" class="text-field positive w-input" name={`link-${index}`} id={index} required />
                                            </div>
                                            <div class="w-col w-col-2 w-col-small-2 w-col-tiny-2">
                                                <span onclick={() => onClickRemoveLink(link, index)} class="btn btn-small btn-terciary fa fa-lg fa-trash btn-no-border" aria-hidden="true"></span>
                                            </div>
                                        </div>
                                    ))
                                }
                                <div class="w-row">
                                    <div class="w-col w-col-6"></div>
                                    <div class="w-col w-col-6">
                                        <span onclick={onClickToAddNewLink} class="btn btn-small btn-terciary">
                                            + &nbsp; Adicionar link
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

        )
    }
}