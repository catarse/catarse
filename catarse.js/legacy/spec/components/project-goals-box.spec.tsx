declare function describe(name : string, test : Function)
declare function it(name : string, test : Function)

import m from 'mithril'
import prop from 'mithril/stream'
import mq from 'mithril-query'
import _ from 'underscore'
import { GoalDetails } from '../../src/entities/goal-details'
import ProjectGoalsBox from '../../src/c/project-goals-box'


function mockGoalsDetails(mocks : number) : prop<GoalDetails[]> {
    return prop(_.times(mocks, n => (
        {
            title: `Goal ${n+1}`,
            description: `Goal ${n+1} description`,
            value: 100 * (n + 1),
        } as GoalDetails
    )))
} 

describe('ProjectGoalsBox', () => {
    const goalsDetails = mockGoalsDetails(4)

    it('should render first of 4 goals', () => {
        // arrange
        const subscriptionData = prop({ amount_paid_for_valid_period: 0 })
        const viewingGoal = _.first(goalsDetails())
        const component = mq(<ProjectGoalsBox subscriptionData={subscriptionData} goalDetails={goalsDetails} style='' />)
        
        // act...

        // assert
        component.should.contain(viewingGoal.title)
        component.should.contain(`R$${subscriptionData().amount_paid_for_valid_period} de R$${viewingGoal.value} por mês`)
        component.should.contain(viewingGoal.description)
    })

    it('should move to the next goal', () => {

        // arrange
        const viewingGoal = goalsDetails()[1]
        const subscriptionData = prop({ amount_paid_for_valid_period: 0 })
        const component = mq(<ProjectGoalsBox subscriptionData={subscriptionData} goalDetails={goalsDetails} style='' />)

        // act
        component.click('button:last-child', new Event('click'))

        // assert
        component.should.contain(viewingGoal.title)
        component.should.contain(`R$${subscriptionData().amount_paid_for_valid_period} de R$${viewingGoal.value} por mês`)
        component.should.contain(viewingGoal.description)
    })

    it('should move to the last goal', () => {

        // arrange
        const viewingGoal = _.last(goalsDetails())
        const subscriptionData = prop({ amount_paid_for_valid_period: 0 })
        const component = mq(<ProjectGoalsBox subscriptionData={subscriptionData} goalDetails={goalsDetails} style='' />)

        // act
        component.click('button:last-child', new Event('click'))
        component.click('button:last-child', new Event('click'))
        component.click('button:last-child', new Event('click'))

        // assert
        component.should.contain(viewingGoal.title)
        component.should.contain(`R$${subscriptionData().amount_paid_for_valid_period} de R$${viewingGoal.value} por mês`)
        component.should.contain(viewingGoal.description)
    })

    it('should move to the last goal and go back to the first', () => {

        // arrange
        const viewingGoal = _.first(goalsDetails())
        const subscriptionData = prop({ amount_paid_for_valid_period: 0 })
        const component = mq(<ProjectGoalsBox subscriptionData={subscriptionData} goalDetails={goalsDetails} style='' />)

        // act
        // act. move to last goal
        component.click('button:last-child', new Event('click'))
        component.click('button:last-child', new Event('click'))
        component.click('button:last-child', new Event('click'))

        // act. go back to the first
        component.click('button:first-child', new Event('click'))
        component.click('button:first-child', new Event('click'))
        component.click('button:first-child', new Event('click'))


        // assert
        component.should.contain(viewingGoal.title)
        component.should.contain(`R$${subscriptionData().amount_paid_for_valid_period} de R$${viewingGoal.value} por mês`)
        component.should.contain(viewingGoal.description)
    })
})