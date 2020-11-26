type StringEmptyOrNull = string | '' | null

export type UserAddress = {
    
    // When not international
    state_id: number
    address_number: StringEmptyOrNull
    address_complement: StringEmptyOrNull
    address_neighbourhood: StringEmptyOrNull
    phone_number: StringEmptyOrNull
    
    // anyway
    country_id: number
    address_street: StringEmptyOrNull
    address_city: StringEmptyOrNull
    address_state: StringEmptyOrNull
    address_zip_code: StringEmptyOrNull

    id: number
    common_id: StringEmptyOrNull
    created_at: StringEmptyOrNull
    updated_at: StringEmptyOrNull
}