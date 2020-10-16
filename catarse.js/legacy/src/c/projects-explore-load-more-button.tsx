import m from 'mithril';

export type ProjectsExploreLoadMoreButtonAttrs = {
    showNextPageButton: boolean;
    onclick(event : Event): boolean;
}

export const ProjectsExploreLoadMoreButton : m.Component<ProjectsExploreLoadMoreButtonAttrs> = {
    view({attrs}) {
        const showNextPageButton = attrs.showNextPageButton;
        const onclick = attrs.onclick;

        return (
            <div class="w-section u-marginbottom-80">
                <div class="w-container">
                    <div class="w-row">
                        {
                            showNextPageButton &&
                            <div class="w-col w-col-2 w-col-push-5">
                                <a href="#" onclick={onclick} class="btn btn-medium btn-terciary">
                                    Carregar mais
                                </a>
                            </div>
                        }
                    </div>
                </div>
            </div>
        );
    }
};