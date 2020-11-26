import m from 'mithril'

export type BlogBannerPostProps = {
    href: string
    title: string
    summary: string
}

export default class BlogBannerPost implements m.Component {
    view({attrs: { href, title, summary }} : m.Vnode<BlogBannerPostProps>) {
        return (
            <div class="w-col w-col-4 col-blog-post">
                <a href={href} class="link-hidden fontweight-semibold fontsize-base u-marginbottom-10" target="_blank">
                    {title}
                </a>
                <div class="fontsize-smaller fontcolor-secondary u-margintop-10">
                    {summary}
                </div>
            </div>
        )
    }
}