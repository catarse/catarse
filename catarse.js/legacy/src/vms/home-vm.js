import m from 'mithril';
import h from '../h';

/**
 * @typedef {Object} HomeBanner
 * @property {number} id
 * @property {string} title
 * @property {string} subtitle
 * @property {string} link
 * @property {string} cta
 * @property {string} image
 * @property {string} created_at
 * @property {string} updated_at
 */

/**
 * @typedef {Object} HomeVM
 * @property {Array<HomeBanner>} banners
 * @property {boolean} isUpdating
 */

const homeVM = () => {
    const _isUpdating = h.RedrawStream(false);
    const _banners =  h.RedrawStream([]);

    async function getBanners() {

        try {
            const response = await m.request('/home_banners');
            _banners(response.data);
        } catch(e) {
            _banners([]);
        }
    }

    /** @param {Array<HomeBanner>} newBanners */
    async function updateBanners(newBanners) {

        _isUpdating(true);

        try {
            for (const newBannerData of newBanners) {

                const response = await m.request({
                    method: 'put',
                    url: `/home_banners/${newBannerData.id}/`,
                    data: newBannerData,
                    config: h.setCsrfToken
                });
            }
        } catch(e) {
            console.log('error updating banners:', e);
        }

        _isUpdating(false);
    }

    getBanners();
    
    return {
        /** @type {Array<HomeBanner>} */
        get banners() {
            return _banners;
        },

        /** @param {Array<HomeBanner>} newBanners */
        set banner(newBanners) {
            updateBanners(newBanners);
        },

        /** @type {boolean} */
        get isUpdating() {
            return _isUpdating()
        },

        updateBanners
    };
};

export default homeVM;