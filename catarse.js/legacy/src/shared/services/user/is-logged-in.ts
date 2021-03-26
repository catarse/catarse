import { UserDetails } from '../../../entities'

export const isLoggedIn = (user: UserDetails | null) => user && !user.is_null && !!user?.id
