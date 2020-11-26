import _ from 'underscore';
import m from 'mithril';
import h from '../h';

const blogVM = {
    async getBlogPosts() {
        try {
            const posts = document.body.getAttribute('data-blog')
            if (posts) {
                return JSON.parse(posts)
            } else {
                return m.request({ method: 'GET', url: '/posts' })
            }
        } catch (error) {
            throw error
        } finally {
            h.redraw()
        }
    }
};

export default blogVM;
