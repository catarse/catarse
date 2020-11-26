import m from 'mithril';

export const ExploreProjectsFoundCounter : m.Component<{ total: number; }> = {
    view({attrs, children}) {
        
        const total = attrs.total;

        return (
            <div>
                <div class="w-container">
                    <div class="w-row">
                        <div class="w-col w-col-9 w-col-tiny-9 w-col-small-9">
                            <div class="fontsize-large">
                                {total} projetos encontrados
                            </div>
                            {children}
                        </div>
                        <div class="w-col w-col-3 w-col-tiny-3 w-col-small-3">
                        </div>
                    </div>
                </div>
            </div>
        );
    }
};