import { apiCatarseAddress } from '../../../../../../lib/configs/apis-address'
import { Bank } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'
import { loadBanks } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases'

describe('LoadBanks', () => {

    it('should load banks', async () => {
        // 1. Arrange
        const banks : Bank[] = [
            {
                id: 1,
                code: '104',
                name: 'CEF'
            },
            {
                id: 2,
                code: '341',
                name: 'Itaú'
            }
        ]
        const loadUrl = `${apiCatarseAddress}/banks`
        jasmine.Ajax.stubRequest(loadUrl).andReturn({
            responseText: JSON.stringify(banks)
        })

        // 2. Act
        const banksLoaded = await loadBanks()

        // 3. Assert
        expect(banksLoaded).toEqual(jasmine.objectContaining(banks))
    })
})