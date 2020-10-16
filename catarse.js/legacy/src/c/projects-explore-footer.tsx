import m from 'mithril';

export type ProjectsExplorerFooterAttrs = {
    hasSpecialFooter: boolean;
    icon: string;
    title: string;
    link: string;
    cta: string;
}

export const ProjectsExplorerFooter : m.Component<ProjectsExplorerFooterAttrs> = {
    view({attrs}) {
        const hasSpecialFooter = attrs.hasSpecialFooter;
        const icon = attrs.icon;
        const title = attrs.title;
        const link = attrs.link;
        const cta = attrs.cta;

        const iconSrc = hasSpecialFooter ? icon : 'https://daks2k3a4ib2z.cloudfront.net/54b440b85608e3f4389db387/56f4414d3a0fcc0124ec9a24_icon-launch-explore.png';
        const footerTitle = hasSpecialFooter ? title : 'Lance sua campanha no Catarse!';
        const startLink = hasSpecialFooter ? `${link}?ref=ctrse_explore` : '/start?ref=ctrse_explore';
        const startLinkTitle = hasSpecialFooter ? cta : 'Aprenda como';

        return (
            <div class="w-section section-large before-footer u-margintop-80 bg-gray divider">
                <div class="w-container u-text-center">
                    <img src={iconSrc} class="u-marginbottom-20 icon-hero"/>
                    <h2 class="fontsize-larger u-marginbottom-60">
                        {footerTitle}
                    </h2>
                    <div class="w-row">
                        <div class="w-col w-col-4 w-col-push-4">
                            <a href={startLink} class="w-button btn btn-large">{startLinkTitle}</a>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
};