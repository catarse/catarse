import m from 'mithril';
import Stream from 'mithril/stream';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import blogVM from '../vms/blog-vm';
import BlogBannerPost from './blog-banner-post';

type BlogBannerState = {
    posts: Stream<string[][][]>
    error: Stream<string | boolean>
}

export default class BlogBanner implements m.Component {
    oninit({state}) {
        const posts = prop<string[][][]>([])
        const error = prop(false)

        async function loadPosts() {
            try {
                posts(await blogVM.getBlogPosts())
            } catch (e) {
                console.log('BlogBanner error', e)
                error(e)
            } finally {
                h.redraw()
            }
        }
        loadPosts()
        state.posts = posts;
        state.error = error;
    }

    view({state} : m.Vnode<{}, BlogBannerState> ) {
        const posts = state.posts() || []
        const hasError = state.error() || false
        return (
            <section class="section-large bg-gray before-footer" id="blog">
                <div class="w-container">
                    <div class="u-text-center">
                        <a href="https://blog.catarse.me" target="blank">
                            <img src="/assets/icon-blog.png" alt="Icon blog" class="u-marginbottom-10"/>
                        </a>
                        <div class="fontsize-large u-marginbottom-60 text-success">
                            <a href="https://blog.catarse.me" class="link-hidden-success" target="__blank">
                                Blog do Catarse
                            </a>
                        </div>
                    </div>
                    <div class="w-row">
                        {
                            posts.map(post => {
                                const postHref = (post && post[1] && post[1][1]) || ''
                                const postTitle = (post && post[0] && post[0][1]) || ''
                                const postContent = (post && post[3] && post[3][1]) || ''
                                const postShrinkedContent = m.trust(`${h.strip(postContent).substr(0, 130)}...`)
                                return (
                                    <BlogBannerPost
                                        href={postHref}
                                        title={postTitle}
                                        summary={postShrinkedContent}
                                    />
                                )
                            })
                        }
                    </div>
                    {
                        hasError &&
                        <div class="w-row">
                            <div class="w-col w-col-12 u-text-center">
                                Erro ao carregar posts...
                            </div>
                        </div>
                    }
                </div>
            </section>
        )
    }
}
