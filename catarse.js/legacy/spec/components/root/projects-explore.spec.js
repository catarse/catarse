import mq from 'mithril-query';
import m from 'mithril';
import projectsExplore from '../../../src/root/projects-explore';

describe('ProjectsExplore', () => {
    let $output, project, component;
    

    beforeAll(() => {
        // window.onpopstate = function() {}        

        component = m(projectsExplore, { root: { getAttribute: (x) => { return null; }} });
        $output = mq(component);
    });

    it('should render search container', () => {
        $output.should.have('.hero-search');
    });

    describe('view', () => {

        let $outputWithSubscriptionsSelected, $outputWithAonFlexSelected, $outputAllModes;

        beforeAll(() => {
            $outputAllModes = mq(m(projectsExplore));
            $outputWithSubscriptionsSelected = mq(m(projectsExplore, { mode: 'sub', filter: 'all' }));
            $outputWithAonFlexSelected = mq(m(projectsExplore, { mode: 'not_sub', filter: 'all' }));
        });

        it('should render explore with all modes', () => {  
            expect($outputAllModes.contains('Todos os projetos')).toBeTrue();
        });

        it('should render explorer selecting subscriptions', () => {
            expect($outputWithSubscriptionsSelected.contains('Assinaturas')).toBeTrue();
        });

        it('should render explorer selecting aon and flex', () => {
            expect($outputWithAonFlexSelected.contains('Projetos pontuais')).toBeTrue();
        });
    });
});
