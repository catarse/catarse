/**
 * window.c.Slider component
 * Build a slider from any array of mithril elements
 *
 * Example of use:
 * view: () => {
 *     ...
 *     m.component(c.Slider, {
 *         slides: [m('slide1'), m('slide2'), m('slide3')],
 *         title: 'O que estão dizendo por aí...'
 *     })
 *     ...
 * }
 */

import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';

const slider = {
    oninit: function(vnode) {
        let interval;
        const selectedSlideIdx = prop(0),
            translationSize = prop(1600),
            sliderTime = vnode.attrs.sliderTime || 6500,
            decrementSlide = () => {
                if (selectedSlideIdx() > 0) {
                    selectedSlideIdx(selectedSlideIdx() - 1);
                } else {
                    selectedSlideIdx(vnode.attrs.slides().length - 1);
                }
            },
            incrementSlide = () => {
                if (selectedSlideIdx() < (vnode.attrs.slides().length - 1)) {
                    selectedSlideIdx(selectedSlideIdx() + 1);
                } else {
                    selectedSlideIdx(0);
                }
            },
            startSliderTimer = () => {
                interval = setInterval(() => {
                    incrementSlide();
                    m.redraw();
                }, sliderTime);
            },
            resetSliderTimer = () => {
                clearInterval(interval);
                startSliderTimer();
            },
            translationSizeAndRedraw = localVnode => {
                translationSize(Math.max(document.documentElement.clientWidth, window.innerWidth || 0));
                m.redraw();
            },
            clearTheIntervalSettle = localVnode => clearInterval(interval);

        startSliderTimer();

        vnode.state = {
            translationSizeAndRedraw,
            clearTheIntervalSettle,
            selectedSlideIdx,
            translationSize,
            decrementSlide,
            incrementSlide,
            resetSliderTimer
        };
    },
    view: function({state, attrs}) {
        
        const slideClass = attrs.slideClass || '';
        const slideComponent = attrs.slideComponent || '';
        const wrapperClass = attrs.wrapperClass || '';
        const effect = attrs.effect || 'slide';
        const sliderClick = (fn, param) => {
            fn(param);
            state.resetSliderTimer();
            attrs.onchange && attrs.onchange();
        };
        
        const effectStyle = (idx, translateStr) => {
            const slideFx = `transform: ${translateStr}; -webkit-transform: ${translateStr}; -ms-transform:${translateStr}`;
            const fadeFx = idx === state.selectedSlideIdx() ? 'opacity: 1; visibility: visible;' : 'opacity: 0; visibility: hidden;';
            return effect === 'fade' ? fadeFx : slideFx;
        };

        return m(`.w-slider.${wrapperClass}`, {
            oncreate: state.translationSizeAndRedraw,
            onremove: state.clearTheIntervalSettle,
        }, [
            m('.fontsize-larger', attrs.title),
            m('.w-slider-mask', [
                _.map(attrs.slides(), (slide, idx) => {
                    let translateValue = (idx - state.selectedSlideIdx()) * state.translationSize(),
                        translateStr = `translate3d(${translateValue}px, 0, 0)`;

                    const sliderTransitionStyle = effectStyle(idx, translateStr);
                    return m(slideComponent, {
                        slide,
                        slideClass,
                        sliderTransitionStyle,
                    });
                }),
                m('#slide-prev.w-slider-arrow-left.w-hidden-small.w-hidden-tiny', {
                    onclick: () => sliderClick(state.decrementSlide)
                }, [
                    m('.w-icon-slider-left.fa.fa-lg.fa-angle-left.fontcolor-terciary')
                ]),
                m('#slide-next.w-slider-arrow-right.w-hidden-small.w-hidden-tiny', {
                    onclick: () => sliderClick(state.incrementSlide)
                }, [
                    m('.w-icon-slider-right.fa.fa-lg.fa-angle-right.fontcolor-terciary')
                ]),
                m('.w-slider-nav.w-slider-nav-invert.w-round.slide-nav', _(attrs.slides().length).times(idx => m(`.slide-bullet.w-slider-dot${state.selectedSlideIdx() === idx ? '.w-active' : ''}`, {
                    onclick: () => sliderClick(state.selectedSlideIdx, idx)
                })))
            ])
        ]);
    }
};

export default slider;
