import { Bank } from './entities'

export type LoadBanks = () => Promise<Bank[]>

type BuildParams = {
    loadBanks() : Promise<Bank[]>
    redraw(): void
}

export function createBanksLoader({ loadBanks, redraw } : BuildParams) : LoadBanks {
    return async () => {
        try {
            const banks : Bank[] = await loadBanks()
            return banks
        } catch(e) {
            return [] as Bank[]
        } finally {
            redraw()
        }
    }
}