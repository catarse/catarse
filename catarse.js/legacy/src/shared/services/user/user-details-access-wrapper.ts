import { UserDetails, UserLink, UserMailMarket } from "../../../entities"
import { UserAddress } from "../../../entities/user-address"
import h from "../../../h"
import { getApplicationContext } from "./get-application-context"
import { tryAccessPropertyValue } from "./try-access-property-value"

export class UserDetailsAccessWrapper implements UserDetails {

    get isLoggedIn(): boolean {
        return !!this._user
    }

    get about_html(): string {
        return tryAccessPropertyValue('user', this._user, 'about_html')
    }

    set about_html(value: string) {
        this._user.about_html = value
    }

    get account_type(): string {
        return tryAccessPropertyValue('user', this._user, 'account_type')
    }

    set account_type(value: string) {
        this._user.account_type = value
    }

    get address(): UserAddress {
        return tryAccessPropertyValue('user', this._user, 'address')
    }

    set address(value: UserAddress) {
        this._user.address = value
    }

    get birth_date(): string {
        return tryAccessPropertyValue('user', this._user, 'birth_date')
    }

    set birth_date(value: string) {
        this._user.birth_date = value
    }

    get common_id(): string {
        return tryAccessPropertyValue('user', this._user, 'common_id')
    }

    set common_id(value: string) {
        this._user.common_id = value
    }

    get created_at(): string {
        return tryAccessPropertyValue('user', this._user, 'created_at')
    }

    set created_at(value: string) {
        this._user.created_at = value
    }

    get deactivated_at(): string {
        return tryAccessPropertyValue('user', this._user, 'deactivated_at')
    }

    set deactivated_at(value: string) {
        this._user.deactivated_at = value
    }

    get email(): string {
        return tryAccessPropertyValue('user', this._user, 'email')
    }

    set email(value: string) {
        this._user.email = value
    }

    get email_active(): string {
        return tryAccessPropertyValue('user', this._user, 'email_active')
    }

    set email_active(value: string) {
        this._user.email_active = value
    }

    get facebook_link(): string {
        return tryAccessPropertyValue('user', this._user, 'facebook_link')
    }

    set facebook_link(value: string) {
        this._user.facebook_link = value
    }

    get followers_count(): number {
        return tryAccessPropertyValue('user', this._user, 'followers_count')
    }

    set followers_count(value: number) {
        this._user.followers_count = value
    }

    get following_this_user(): boolean {
        return tryAccessPropertyValue('user', this._user, 'following_this_user')
    }

    set following_this_user(value: boolean) {
        this._user.following_this_user = value
    }

    get follows_count(): number {
        return tryAccessPropertyValue('user', this._user, 'follows_count')
    }

    set follows_count(value: number) {
        this._user.follows_count = value
    }

    get id(): number {
        return tryAccessPropertyValue('user', this._user, 'id')
    }

    set id(value: number) {
        this._user.id = value
    }

    get is_admin(): boolean {
        return tryAccessPropertyValue('user', this._user, 'is_admin')
    }

    set is_admin(value: boolean) {
        this._user.is_admin = value
    }

    get is_admin_role(): boolean {
        return tryAccessPropertyValue('user', this._user, 'is_admin_role')
    }

    set is_admin_role(value: boolean) {
        this._user.is_admin_role = value
    }

    get is_owner_or_admin(): boolean {
        return tryAccessPropertyValue('user', this._user, 'is_owner_or_admin')
    }

    set is_owner_or_admin(value: boolean) {
        this._user.is_owner_or_admin = value
    }

    get links(): UserLink[] {
        return tryAccessPropertyValue('user', this._user, 'links')
    }

    set links(value: UserLink[]) {
        this._user.links = value
    }

    get mail_marketing_lists(): UserMailMarket[] {
        return tryAccessPropertyValue('user', this._user, 'mail_marketing_lists')
    }

    set mail_marketing_lists(value: UserMailMarket[]) {
        this._user.mail_marketing_lists = value
    }

    get name(): string {
        return tryAccessPropertyValue('user', this._user, 'name')
    }

    set name(value: string) {
        this._user.name = value
    }

    get newsletter(): boolean {
        return tryAccessPropertyValue('user', this._user, 'newsletter')
    }

    set newsletter(value: boolean) {
        this._user.newsletter = value
    }

    get owner_document(): string {
        return tryAccessPropertyValue('user', this._user, 'owner_document')
    }

    set owner_document(value: string) {
        this._user.owner_document = value
    }

    get permalink(): string {
        return tryAccessPropertyValue('user', this._user, 'permalink')
    }

    set permalink(value: string) {
        this._user.permalink = value
    }

    get profile_cover_image(): string {
        return tryAccessPropertyValue('user', this._user, 'profile_cover_image')
    }

    set profile_cover_image(value: string) {
        this._user.profile_cover_image = value
    }

    get profile_img_thumbnail(): string {
        return tryAccessPropertyValue('user', this._user, 'profile_img_thumbnail')
    }

    set profile_img_thumbnail(value: string) {
        this._user.profile_img_thumbnail = value
    }

    get public_name(): string {
        return tryAccessPropertyValue('user', this._user, 'public_name')
    }

    set public_name(value: string) {
        this._user.public_name = value
    }

    get state_inscription(): string {
        return tryAccessPropertyValue('user', this._user, 'state_inscription')
    }

    set state_inscription(value: string) {
        this._user.state_inscription = value
    }

    get subscribed_to_friends_contributions(): boolean {
        return tryAccessPropertyValue('user', this._user, 'subscribed_to_friends_contributions')
    }

    set subscribed_to_friends_contributions(value: boolean) {
        this._user.subscribed_to_friends_contributions = value
    }

    get subscribed_to_new_followers(): boolean {
        return tryAccessPropertyValue('user', this._user, 'subscribed_to_new_followers')
    }

    set subscribed_to_new_followers(value: boolean) {
        this._user.subscribed_to_new_followers = value
    }

    get subscribed_to_project_posts(): boolean {
        return tryAccessPropertyValue('user', this._user, 'subscribed_to_project_posts')
    }

    set subscribed_to_project_posts(value: boolean) {
        this._user.subscribed_to_project_posts = value
    }

    get total_contributed_projects(): number {
        return tryAccessPropertyValue('user', this._user, 'total_contributed_projects')
    }

    set total_contributed_projects(value: number) {
        this._user.total_contributed_projects = value
    }

    get total_published_projects() {
        return tryAccessPropertyValue('user', this._user, 'total_published_projects')
    }

    set total_published_projects(value: number) {
        this._user.total_published_projects = value
    }

    get twitter_username(): string {
        return tryAccessPropertyValue('user', this._user, 'twitter_username')
    }

    set twitter_username(value: string) {
        this._user.twitter_username = value
    }

    get is_null(): boolean {
        return this._user === null
    }

    constructor(private _user: UserDetails | null) {

    }

    toJSON() {
        return this._user
    }
}
