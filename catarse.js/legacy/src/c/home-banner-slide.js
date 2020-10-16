import m from 'mithril';

export const HomeBannerSlide = {
    view({attrs}) {

        const {
            slide,
            slideClass,
            sliderTransitionStyle
        } = attrs;

        return m(`.slide.w-slide.${slideClass}`, {
            style: `${sliderTransitionStyle} background-image: url(${slide.image});`
        }, [
            m('.hero-slide-wrapper', [ 
                m('.w-container.u-text-center', [
                    m('.w-row', [
                        m('.w-col.w-col-8.w-col-push-2', [
                            m('h1.hero-home-title', m.trust(slide.title)),
                            m('h2.hero-home-subtitle.u-marginbottom-20', m.trust(slide.subtitle)),
                            m('a.btn.btn-medium.btn-inline', { href: slide.link }, slide.cta)
                        ])
                    ])
                ])
            ])
        ]);
    }
};