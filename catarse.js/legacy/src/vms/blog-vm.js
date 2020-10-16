import _ from 'underscore';
import m from 'mithril';

const blogVM = {
    getBlogPosts() {
        const p = new Promise((resolve, reject) => {
            const posts = _.first(document.getElementsByTagName('body')).getAttribute('data-blog');

            if (posts) {
                resolve(JSON.parse(posts));
                m.redraw();
            } else {
                m.request({ method: 'GET', url: '/posts' })
                    .then(data => {
                        resolve(data);
                        m.redraw();
                    })
                    .catch(err => {
                        reject(err);
                        m.redraw();
                    });
            }
        });

        return p;
    }
};

export default blogVM;
