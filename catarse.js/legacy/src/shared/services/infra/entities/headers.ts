export type HttpHeaders = Partial<{
    [header:string]: string
}> & Partial<Headers>
