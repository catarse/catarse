import { UserAddress } from "./user-address";

type StringEmptyOrNull = string | '' | null
type StringOrNull = string | null

export type UserDetails = {
    about_html: StringEmptyOrNull
    account_type: StringEmptyOrNull
    address: UserAddress | null
    birth_date: StringEmptyOrNull
    common_id: StringEmptyOrNull
    created_at: StringOrNull
    deactivated_at: StringOrNull
    email: StringOrNull
    email_active: StringOrNull
    facebook_link: StringEmptyOrNull
    followers_count: number
    following_this_user: boolean
    follows_count: number
    id: number
    is_admin: boolean
    is_admin_role: boolean
    is_owner_or_admin: boolean | null
    links: {
        id: number | null
        link: StringEmptyOrNull
    }[]
    mail_marketing_lists: {
        user_marketing_list_id: number | null
        marketing_list: string | null
    }[]
    name: StringEmptyOrNull
    newsletter: boolean
    owner_document: StringEmptyOrNull
    permalink: StringEmptyOrNull
    profile_cover_image: StringEmptyOrNull
    profile_img_thumbnail: StringEmptyOrNull
    public_name: StringEmptyOrNull
    state_inscription: StringEmptyOrNull
    subscribed_to_friends_contributions: boolean
    subscribed_to_new_followers: boolean
    subscribed_to_project_posts: boolean
    total_contributed_projects: number
    total_published_projects: number
    twitter_username: StringEmptyOrNull
}