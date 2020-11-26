export interface RailsErrors extends Error {
    errors: string[]
    errors_json: string
}